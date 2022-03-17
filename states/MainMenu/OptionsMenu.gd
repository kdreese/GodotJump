extends ColorRect


func _ready() -> void:
	if OS.get_name() == "HTML5":
		$C/V/PanelContainer/Buttons/FullscreenButton.hide()
	else:
		$C/V/PanelContainer/Buttons/FullscreenButton.pressed = OS.window_fullscreen
	$C/V/PanelContainer/Buttons/SoundButton.pressed = Global.sound_enabled
	$C/V/PanelContainer/Buttons/MusicButton.pressed = Global.music_enabled
	$C/V/OptionsBackButton.grab_focus()


# Handle fullscreen toggling to update fullscreen toggle
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		if OS.get_name() == "HTML5":
			return
		OS.window_fullscreen = not OS.window_fullscreen
		$C/V/PanelContainer/Buttons/FullscreenButton.pressed = OS.window_fullscreen
		get_tree().set_input_as_handled()


func _on_FullscreenButton_toggled(button_pressed: bool) -> void:
	OS.window_fullscreen = button_pressed
	Global.save_game()


func _on_SoundButton_toggled(button_pressed: bool) -> void:
	Global.sound_enabled = button_pressed
	Global.save_game()


func _on_MusicButton_toggled(button_pressed: bool) -> void:
	Global.music_enabled = button_pressed
	Global.save_game()


func _on_OptionsBackButton_pressed() -> void:
	var error := get_tree().change_scene("res://states/MainMenu/MainMenu.tscn")
	assert(not error)
