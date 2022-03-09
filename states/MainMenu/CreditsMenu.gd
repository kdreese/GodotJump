extends ColorRect


func _ready() -> void:
	$VBoxContainer/CreditsBackButton.grab_focus()


func _on_CreditsBackButton_pressed() -> void:
	var error := get_tree().change_scene("res://states/MainMenu/MainMenu.tscn")
	assert(not error)
