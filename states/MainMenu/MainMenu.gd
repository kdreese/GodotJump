extends Control


func _ready() -> void:
	if OS.get_name() == "HTML5":
		$VBoxContainer/Buttons/QuitButton.hide()
	$VBoxContainer/Buttons/PlayButton.grab_focus()


func _on_PlayButton_pressed() -> void:
	var error := get_tree().change_scene("res://states/Game/Game.tscn")
	assert(not error)


func _on_CreditsButton_pressed() -> void:
	var error := get_tree().change_scene("res://states/MainMenu/CreditsMenu.tscn")
	assert(not error)


func _on_OptionsButton_pressed() -> void:
	var error := get_tree().change_scene("res://states/MainMenu/OptionsMenu.tscn")
	assert(not error)


func _on_QuitButton_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
