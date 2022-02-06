extends HBoxContainer
var global_id
var opened_file

onready var file_popup = get_node("FileOptionButton/FilePopupMenu")
onready var OpenFile_dialog = get_node("FileOptionButton/OpenFileDialog")

func _ready():
	pass

func _on_FileOptionButton_pressed():
	file_popup.visible = !file_popup.visible
	pass # Replace with function body.


func _on_FilePopupMenu_id_pressed(id):
	global_id = id
	match id:
		1:
			OpenFile_dialog.popup()
			opened_file = OpenFile_dialog.filename
