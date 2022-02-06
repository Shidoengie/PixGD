extends VBoxContainer

func _on_PentTextureButton_pressed():
	$ErasorTextureButton.pressed = false
	$Eyedropper.pressed = false
	$Bucket.pressed = false
	pass # Replace with function body.


func _on_ErasorTextureButton_pressed():
	$PentTextureButton.pressed = false
	$Eyedropper.pressed = false
	$Bucket.pressed = false


func _on_Eyedropper_pressed():
	$PentTextureButton.pressed = false
	$Bucket.pressed = false
	$ErasorTextureButton.pressed = false

func _on_Bucket_pressed():
	$PentTextureButton.pressed = false
	$Eyedropper.pressed = false
	$ErasorTextureButton.pressed = false
