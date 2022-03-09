extends Node


const CONFIG_PATH := "user://config.cfg"


var high_score := 0


func _ready() -> void:
	set_pause_mode(PAUSE_MODE_PROCESS)
	load_game()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		if OS.get_name() == "HTML5":
			return
		OS.window_fullscreen = not OS.window_fullscreen
		get_tree().set_input_as_handled()


func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
		get_tree().quit()


func load_game() -> void:
	var config_file := File.new()
	var error := config_file.open(CONFIG_PATH, File.READ)
	if error:
		return

	var config = str2var(config_file.get_as_text())
	config_file.close()

	if not typeof(config) == TYPE_DICTIONARY:
		return

	if OS.get_name() != "HTML5":
		if "fullscreen" in config and typeof(config["fullscreen"]) == TYPE_BOOL:
			OS.window_fullscreen = config["fullscreen"]

	if "high_score" in config and typeof(config["high_score"]) == TYPE_INT:
		high_score = config["high_score"]


func save_game() -> void:
	var config := {}

	if OS.get_name() != "HTML5":
		config["fullscreen"] = OS.window_fullscreen

	config["high_score"] = high_score

	var config_file := File.new()
	var error := config_file.open(CONFIG_PATH, File.WRITE)
	if error:
		print("Error, could not save game")
		return

	config_file.store_line(var2str(config))
	config_file.close()
