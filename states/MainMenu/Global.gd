extends Node


var high_score := 0


func _ready() -> void:
	set_pause_mode(PAUSE_MODE_PROCESS)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		if OS.get_name() == "HTML5":
			return
		OS.window_fullscreen = not OS.window_fullscreen
		get_tree().set_input_as_handled()
