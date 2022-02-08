extends HBoxContainer

onready var edit_popup = get_node("EditOptionButton/EditPopupMenu")
onready var file_popup = get_node("FileOptionButton/FilePopupMenu")
onready var open_file_dialog = get_node("FileOptionButton/OpenFileDialog")
onready var save_file_dialog = get_node("FileOptionButton/SaveFileDialog")


func _on_FileOptionButton_pressed():
	file_popup.popup(Rect2(Vector2(0,32),Vector2(120,92)))

func _on_FilePopupMenu_id_pressed(id):
	match id:
		0:
			$FileOptionButton/ConfirmationDialog.popup()
		1:
			open_file_dialog.popup()
		2:
			save_file_dialog.popup()
		3:
			pass


func _on_cancel_pressed():
	$FileOptionButton/ConfirmationDialog.hide()


func _on_EditOptionButton_pressed():
	edit_popup.popup(Rect2(Vector2(0,21),Vector2(120,64)))
	
	pass # Replace with function body.
