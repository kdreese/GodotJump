extends Control


var score: int


onready var score_label := $ScoreLabel as Label
onready var game_over_score_label := $GameOver/PanelContainer/VBoxContainer/ScoreLabel as Label
onready var game_over_high_score_label := $GameOver/PanelContainer/VBoxContainer/HighScoreLabel as Label

onready var score_text = score_label.text
onready var game_over_score_text := game_over_score_label.text
onready var game_over_high_score_text := game_over_high_score_label.text


func set_score(new_score):
	score = new_score
	score_label.text = score_text % score


func game_over():
	game_over_score_label.text = game_over_score_text % score
	if score > Global.high_score:
		Global.high_score = score
		game_over_high_score_label.add_color_override("font_color", Color.gold)
	game_over_high_score_label.text = game_over_high_score_text % Global.high_score
	$GameOver.show()
	$GameOverAnimationPlayer.play("GameOverAnimation")
	$GameOver/PanelContainer/VBoxContainer/HBoxContainer/ReplayButton.grab_focus()


func _on_ReplayButton_pressed() -> void:
	var error := get_tree().reload_current_scene()
	assert(not error)


func _on_QuitButton_pressed() -> void:
	var error = get_tree().change_scene("res://states/MainMenu/MainMenu.tscn")
	assert(not error)
