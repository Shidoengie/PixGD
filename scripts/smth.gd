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
onready var bg = get_node("Canvas/Canvas2")
onready var fill_button = get_node("CanvasLayer/VBoxContainer/Bucket")

var img_mousepos
var texture = ImageTexture.new()
var nimg = Image.new()
var mouse_down = false
var relev

func _ready():
	set_as_toplevel(true)
	nimg.create(64,64,false,Image.FORMAT_RGBA8)
	bg.scale.x = nimg.get_size().x / bg.texture.get_size().x
	bg.scale.y = nimg.get_size().y / bg.texture.get_size().y
func _process(delta):
	img_mousepos = img.get_local_mouse_position()
	texture.create_from_image(nimg,0)
	img.texture = texture
	ui_input()
	relev = img.get_local_mouse_position()
var i = 0.1
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

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				textfield.text = str(((1/cam.zoom.x)*100))
				cam.zoom /= Vector2(1.5,1.5)
			if event.button_index == BUTTON_WHEEL_DOWN:
				textfield.text = str(((1/cam.zoom.x)*100))
				cam.zoom *= Vector2(1.5,1.5)
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("ui_middle_click"):
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
