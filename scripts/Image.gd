extends Node2D

onready var textfield = get_node("CanvasLayer/VBoxContainer2/LineEdit")
onready var slider = get_node("CanvasLayer/VBoxContainer2/HSlider")
onready var img = get_node("Canvas")
onready var color_picker = get_node("CanvasLayer/ColorPicker")
onready var color_picker2 = get_node("CanvasLayer/ColorPicker2")
onready var cam = get_node("Camera2D")
onready var ers_button = get_node("CanvasLayer/VBoxContainer/ErasorTextureButton")
onready var pen_button = get_node("CanvasLayer/VBoxContainer/PentTextureButton")
onready var eyedropper_button = get_node("CanvasLayer/VBoxContainer/Eyedropper")
onready var trans_bg = get_node("Canvas/Canvas2")
onready var fill_button = get_node("CanvasLayer/VBoxContainer/Bucket")
onready var open_file_dialog = get_node("CanvasLayer/Menu/FileOptionButton/OpenFileDialog")
onready var save_file_dialog = get_node("CanvasLayer/Menu/FileOptionButton/SaveFileDialog")
onready var width_new_file = get_node("CanvasLayer/Menu/FileOptionButton/ConfirmationDialog/Width")
onready var height_new_file = get_node("CanvasLayer/Menu/FileOptionButton/ConfirmationDialog/Height")
onready var new_file_bg = get_node("CanvasLayer/Menu/FileOptionButton/ConfirmationDialog/ColorPickerTextButton")
onready var trans_button = get_node("CanvasLayer/Menu/FileOptionButton/ConfirmationDialog/TransButton")

var save_path = ""
var mouse_action
var img_mousepos
var texture = ImageTexture.new()
var nimg = Image.new()
var mouse_down = false
var relev

func _ready():
	set_as_toplevel(true)
	nimg.create(64,64,false,Image.FORMAT_RGBA8)
func _process(delta):
	trans_bg.scale.x = nimg.get_size().x / trans_bg.texture.get_size().x
	trans_bg.scale.y = nimg.get_size().y / trans_bg.texture.get_size().y
	img_mousepos = img.get_local_mouse_position()
	texture.create_from_image(nimg,0)
	img.texture = texture
	if Input.is_action_just_pressed("save") and save_path != "":
		nimg.save_png(save_path)
	elif Input.is_action_just_pressed("save"):
		 save_file_dialog.popup()
	mouse_action = Input.is_action_pressed("ui_click_l") or Input.is_action_pressed("ui_click_r")
	
	
var i = 0.1
func paint(color):
	nimg.lock()
	while i<1:
		var interlerp = Vector2(lerp(img_mousepos.x,relev.x,i),lerp(img_mousepos.y,relev.y,i))
		if interlerp.x > nimg.get_size().x or interlerp.x < 0 or interlerp.y > nimg.get_size().y or interlerp.y < 0:
			break
		nimg.set_pixel(interlerp.x,interlerp.y,color)
		i+=0.01
	i = 0

func _on_LineEdit_text_entered(new_text):
	scroll()
	slider.value = int(textfield.text)

func _on_HSlider_value_changed(value):
	scroll()
	textfield.text = str(slider.value)

func scroll():
	cam.zoom = Vector2(1,1)
	cam.zoom /= Vector2(int(textfield.text)/100,int((textfield.text))/100)

func ui_input():
	if img_mousepos.x >= nimg.get_size().x or img_mousepos.x < 0 or img_mousepos.y >= nimg.get_size().y or img_mousepos.y < 0:
		return
	if Input.is_action_pressed("ui_click_l"):
		nimg.lock()
		if pen_button.pressed:
				paint(color_picker.color)
		elif ers_button.pressed:
				paint(Color.transparent)
		elif eyedropper_button.pressed:
			color_picker.color = nimg.get_pixel(img_mousepos.x,img_mousepos.y)
		elif fill_button.pressed:
			floodfill(img_mousepos.x,img_mousepos.y,color_picker.color)
	elif Input.is_action_pressed("ui_click_r"):
		nimg.lock()
		if pen_button.pressed:
				paint(color_picker2.color)
		elif ers_button.pressed:
				paint(Color.transparent)
		elif eyedropper_button.pressed:
			color_picker2.color = nimg.get_pixel(img_mousepos.x,img_mousepos.y)
		elif fill_button.pressed:
			floodfill(img_mousepos.x,img_mousepos.y,color_picker2.color)

func _unhandled_input(event):
	relev = img.get_local_mouse_position()
	if event is InputEventMouseButton or event is InputEventMouseMotion and mouse_action:
		ui_input()
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				textfield.text = str(((1/cam.zoom.x)*100))
				cam.zoom /= Vector2(1.5,1.5)
			if event.button_index == BUTTON_WHEEL_DOWN:
				textfield.text = str(((1/cam.zoom.x)*100))
				cam.zoom *= Vector2(1.5,1.5)
	if event is InputEventMouseMotion and Input.is_action_pressed("ui_middle_click"):
		cam.position -= event.relative*cam.zoom

func floodfill(x,y,color):
	nimg.lock()
	var w = nimg.get_height()
	var h = nimg.get_width()
	var old_color = nimg.get_pixel(x,y)
	if color == old_color:
			return
	var queue = []
	queue.append(Vector2(x,y))
	while len(queue) > 0:
		var coords = queue.pop_back()
		x = coords.x
		y = coords.y
		if x < 0 or x > w or y < 0 or y>h or nimg.get_pixel(x,y) != old_color:
			continue
		else:
			nimg.set_pixel(x,y,color)
			queue.append(Vector2(x,y+1))
			queue.append(Vector2(x,y-1))
			queue.append(Vector2(x+1,y))
			queue.append(Vector2(x-1,y))


func _on_OpenFileDialog_file_selected(path):
	nimg.load(path)
	save_path = path
func _on_SaveFileDialog_file_selected(path):
	nimg.save_png(path)
	save_path = path

func _on_ok_pressed():
	nimg.unlock()
	nimg.create(width_new_file.value,height_new_file.value,false,Image.FORMAT_RGBA8)
	if new_file_bg.pressed:
		nimg.fill(new_file_bg.color)
	elif trans_button.pressed:
		nimg.fill(Color.transparent)
	$CanvasLayer/Menu/FileOptionButton/ConfirmationDialog.hide()



func _on_FilePopupMenu_id_pressed(id):
	if id == 3:
		if save_path != "":
			nimg.save_png(save_path)
		else:
			save_file_dialog.popup()
