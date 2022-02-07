extends HBoxContainer
var global_id
var opened_file

onready var file_popup = get_node("FileOptionButton/FilePopupMenu")
onready var open_file_dialog = get_node("FileOptionButton/OpenFileDialog")
onready var save_file_dialog = get_node("FileOptionButton/SaveFileDialog")

func _ready():
	open_file_dialog.current_file.get_file()
	
	pass

func _on_FileOptionButton_pressed():
	file_popup.visible = !file_popup.visible
	pass # Replace with function body.


func _on_FilePopupMenu_id_pressed(id):
	global_id = id
	match id:
		1:
			open_file_dialog.popup()
			opened_file = open_file_dialog.filename
		2:
			save_file_dialog.popup()
