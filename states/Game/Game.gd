extends Node2D


const CHUNK_TABLE = [
#	[name,               randomization, spawn probabilities array(SPA)]
	["BaseTemplate",             true,  [50.0, 40.0, 30.0, 15.0]],
	["BaseTemplate",             false, [10.0, 5.0,  0.0,  0.0]],
	["SquishTemplate",           true,  [25.0, 20.0, 12.5, 7.5]],
	["SquishTemplate",           false, [10.0, 5.0,  0.0,  0.0]],
	["SpacedTemplate",           true,  [5.0,  10.0, 30.0, 30.0]],
	["BaseSpringTemplate",       true,  [0.0,  10.0, 10.0, 10.0]],
	["BaseJetpackTemplate",      true,  [0.0,  10.0, 10.0, 10.0]],
	["BaseBlackholeTemplate",    true,  [0.0,  0.0,  2.5,  20.0]],
	["BaseBlackholeTemplate",    false, [0.0,  0.0,  2.5,  0.0]],
	["BlackholeReverseTemplate", false, [0.0,  0.0,  2.5,  0.0]],
	["BlackholeAvoidTemplate",   false, [0.0,  0.0,  0.0,  7.5]],
]
# Each unit of SPA corresponds to a range in the breakpoints
# http://www.kehomsforge.com/tutorials/single/GDWeightedRandom

const SPAWN_PROBABILITY_BREAKPOINTS = [500, 1500, 2500]

const Platform = preload("res://objects/Platform/Platform.tscn")

const PLATFORM_OFFSCREEN_OFFSET := 100.0
const PLATFORM_RANGE = 250.0	# The max horizontal range from the center of the viewport the platforms will vary

# Initialize the table with the values associated with the easiest difficulty
var spawn_probability_table = [50.0, 60.0, 85.0, 95.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0]
var spawn_level := 0
var total_probability := 100.0

var score: int

onready var next_chunk_spawn_y := ($GameObjects/ChunkStart as Position2D).position.y
onready var highest_y := ($GameObjects/Jumper as KinematicBody2D).position.y
onready var camera_y_offset := ($Camera2D as Camera2D).position.y


func _ready() -> void:
	randomize()
	$GameObjects/ChunkStart.free()
	if Global.music_enabled:
		$BackgroundMusic.play()

	generate_chunks()


func _process(_delta: float) -> void:
	var jumper: KinematicBody2D = get_node_or_null("GameObjects/Jumper")
	if jumper == null:
		return
	if jumper.position.y < highest_y:
		highest_y = jumper.position.y
	$Camera2D.position.y = highest_y + camera_y_offset
	score = (-highest_y / 10) as int
	$CanvasLayer/UI.set_score(score)
	# Increment spawning difficulty level
	if (spawn_level < SPAWN_PROBABILITY_BREAKPOINTS.size()) and (score > SPAWN_PROBABILITY_BREAKPOINTS[spawn_level]):
		spawn_level += 1
		total_probability = 0.0
		for i in spawn_probability_table.size():
			total_probability += CHUNK_TABLE[i][2][spawn_level]
			spawn_probability_table[i] = total_probability


func _physics_process(_delta: float) -> void:
	var view_size = get_viewport_rect().size
	var view_bottom_y = $Camera2D.global_position.y + $Camera2D.offset.y + view_size.y / 2

	for child in $GameObjects.get_children():
		if child.position.y > view_bottom_y + PLATFORM_OFFSCREEN_OFFSET:
			child.queue_free()

	generate_chunks()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("pause_escape"):
		if not $CanvasLayer/UI/GameOver.visible:
			get_tree().paused = true
			$CanvasLayer/PauseScreen.visible = true
			$CanvasLayer/PauseScreen/CenterContainer/VBoxContainer/Buttons/ResumeButton.grab_focus()
			$BackgroundMusic.volume_db = -30


func generate_chunks() -> void:
	var view_size = get_viewport_rect().size
	var view_top_y = $Camera2D.global_position.y + $Camera2D.offset.y - view_size.y / 2

	while view_top_y - PLATFORM_OFFSCREEN_OFFSET < next_chunk_spawn_y:
		var rand := rand_range(0.0, total_probability)
		var table_count := 0
		for i in spawn_probability_table.size():
			if rand <= spawn_probability_table[i]:
				break
			table_count += 1
		var chunk_info := CHUNK_TABLE[table_count] as Array
		spawn_chunk("res://templates/platform_chunks/%s.tscn" % chunk_info[0], chunk_info[1])
		var next_chunk_end := $GameObjects/ChunkEnd as Position2D
		next_chunk_spawn_y = next_chunk_end.position.y
		next_chunk_end.free()


func spawn_chunk(chunk_path: String, randomize_x: bool = false) -> void:
	var chunk := load(chunk_path).instance() as Node2D
	for child in chunk.get_children():
		var position = child.position
		if randomize_x:
			position.x = rand_range(-PLATFORM_RANGE, PLATFORM_RANGE)
		position.y += next_chunk_spawn_y
		chunk.remove_child(child)
		$GameObjects.add_child(child)
		child.position = position
	chunk.queue_free()


func _on_Jumper_game_over() -> void:
	$CanvasLayer/UI.game_over()
	if Global.sound_enabled:
		$DeathSound.play()


func _on_ResumeButton_pressed() -> void:
	get_tree().paused = false
	$CanvasLayer/PauseScreen.visible = false
	$BackgroundMusic.volume_db = -15


func _on_ExitButton_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().change_scene("res://states/MainMenu/MainMenu.tscn")
	assert(not error)
