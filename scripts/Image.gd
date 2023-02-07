extends Node2D

signal UserAction
export var brush_size = 1
onready var textfield = get_node("CanvasLayer/VBoxContainer2/LineEdit")
onready var slider = get_node("CanvasLayer/VBoxContainer2/HSlider")
onready var img = get_node("Canvas")
onready var color_picker = get_node("CanvasLayer/ColorPicker")
onready var color_picker2 = get_node("CanvasLayer/ColorPicker2")
onready var cam = get_node("Camera2D")
onready var trans_bg = get_node("Canvas/Canvas2")
onready var open_file_dialog = get_node("CanvasLayer/Menu/FileOptionButton/OpenFileDialog")
onready var save_file_dialog = get_node("CanvasLayer/Menu/FileOptionButton/SaveFileDialog")
onready var width_new_file = get_node("CanvasLayer/Menu/FileOptionButton/ConfirmationDialog/Width")
onready var height_new_file = get_node("CanvasLayer/Menu/FileOptionButton/ConfirmationDialog/Height")
onready var new_file_bg = get_node("CanvasLayer/Menu/FileOptionButton/ConfirmationDialog/ColorPickerTextButton")
onready var trans_button = get_node("CanvasLayer/Menu/FileOptionButton/ConfirmationDialog/TransButton")

var states = []
var redo_states = []

var buffer = []
var index = 0
var save_path = ""
var mouse_action
var img_mousepos = Vector2.ZERO
var texture = ImageTexture.new()
var canvasImg = Image.new()
var mouse_down = false
var relev
var current_color

func _ready():
	
	set_as_toplevel(true)
	canvasImg.create(64,64,false,Image.FORMAT_RGBA8)
	
func _process(delta):
	
	trans_bg.scale = canvasImg.get_size() / trans_bg.texture.get_size()
	img_mousepos = img.get_local_mouse_position()
	key_input()
	texture.create_from_image(canvasImg,0)
	img.texture = texture
	mouse_action = Input.is_action_pressed("ui_click_l") or Input.is_action_pressed("ui_click_r")
	
	
var i = 0.1
func paint(color):
	canvasImg.lock()
	while i<1:
		var interlerp = Vector2(lerp(img_mousepos.x,relev.x,i),lerp(img_mousepos.y,relev.y,i)) as Vector2
		if interlerp.x > canvasImg.get_size().x or interlerp.x < 0 or interlerp.y > canvasImg.get_size().y or interlerp.y < 0:
			break
		var brushRect = Rect2(interlerp,Vector2(brush_size,brush_size))
		canvasImg.fill_rect(brushRect,color)
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

func key_input():
	if Input.is_action_just_pressed("undo") and len(buffer) > 1:
		undo()
		
		
	if Input.is_action_just_pressed("redo"):
		redo()
		
	if Input.is_action_just_pressed("save") and save_path != "":
		canvasImg.save_png(save_path)
		
	elif Input.is_action_just_pressed("save"):
		save_file_dialog.popup()
	
func mouse_input():
	if img_mousepos >= canvasImg.get_size() or img_mousepos < Vector2.ZERO:
		return
		
	if Input.is_action_just_pressed("ui_click_l"):
		if Global.current_tool == Global.Tools.EYEDROPPER: 
			color_picker.color = canvasImg.get_pixel(img_mousepos.x,img_mousepos.y)
		print(Global.current_tool)
		current_color = color_picker.color
	elif Input.is_action_just_pressed("ui_click_r"):
		if Global.current_tool == Global.Tools.EYEDROPPER: 
			color_picker2.color = canvasImg.get_pixel(img_mousepos.x,img_mousepos.y)
		current_color = color_picker2.color
		
	if Input.is_action_just_released("ui_click_r") or Input.is_action_just_released("ui_click_l"):
		buffer.append(canvasImg.duplicate())
		
	if not mouse_action:
		return
	canvasImg.lock()
	match Global.current_tool:
		Global.Tools.PEN:
			paint(current_color)
		Global.Tools.ERASOR:
			paint(Color.transparent)
		Global.Tools.BUCKET: 
			fill.floodfill(canvasImg,img_mousepos.x,img_mousepos.y,current_color)
		_:
			pass
	

func _unhandled_input(event):
	relev = img.get_local_mouse_position()
	
	if event is InputEventMouseButton or event is InputEventMouseMotion: mouse_input()
		
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			BUTTON_WHEEL_UP:
				cam.zoom /= Vector2(1.5,1.5)
			BUTTON_WHEEL_DOWN:
				cam.zoom *= Vector2(1.5,1.5)
		textfield.text = str(((1/cam.zoom.x)*100))
		
	if event is InputEventMouseMotion and Input.is_action_pressed("ui_middle_click"):
		cam.position -= event.relative*cam.zoom

func _on_OpenFileDialog_file_selected(path):
	canvasImg.load(path)
	save_path = path

func _on_SaveFileDialog_file_selected(path):
	canvasImg.save_png(path)
	save_path = path

func _on_ok_pressed():
	canvasImg.unlock()
	canvasImg.create(width_new_file.value,height_new_file.value,false,Image.FORMAT_RGBA8)
	
	if new_file_bg.pressed:
		canvasImg.fill(new_file_bg.color)
		
	elif trans_button.pressed:
		canvasImg.fill(Color.transparent)
	$CanvasLayer/Menu/FileOptionButton/ConfirmationDialog.hide()

func _on_FilePopupMenu_id_pressed(id):
	if id == 3:
		if save_path != "":
			canvasImg.save_png(save_path)
		else:
			save_file_dialog.popup()

func undo():
	index -= 1
	index = clamp(index,0,len(buffer)-1)
	canvasImg = buffer[index]

func redo():
	index += 1
	index = clamp(index,0,len(buffer)-1)
	canvasImg.copy_from(buffer[index])


func _on_Control_UserAction():

	var current_state = get_CurrentAppstate()
	

func get_CurrentAppstate():
	# PLACEHOLDER in the fucture this will get replaced
	return canvasImg.duplicate()


func _on_BrushSizeInput_value_changed(value):
	brush_size = value
