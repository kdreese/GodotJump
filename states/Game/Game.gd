extends Node2D


const CHUNK_TABLE = [
	["BaseTemplate", true],
	["BaseTemplate", false],
	["SquishTemplate", true],
	["SquishTemplate", false],
	["SpacedTemplate", true],
	["BaseSpringTemplate", true],
	["BaseJetpackTemplate", true],
	["BaseBlackholeTemplate", false],
	["BaseBlackholeTemplate", true],
	["BlackholeReverseTemplate", false],	# reverse template solves for blackhole density on the right
	["BlackholeAvoidTemplate", false],
]

const Platform = preload("res://objects/Platform/Platform.tscn")

const PLATFORM_OFFSCREEN_OFFSET := 100.0
const PLATFORM_RANGE = 250.0	# The max horizontal range from the center of the viewport the platforms will vary

onready var next_chunk_spawn_y := ($GameObjects/ChunkStart as Position2D).position.y
onready var highest_y := ($GameObjects/Jumper as KinematicBody2D).position.y
onready var camera_y_offset := ($Camera2D as Camera2D).position.y


func _ready() -> void:
	randomize()
	$GameObjects/ChunkStart.free()

	generate_chunks()


func _process(_delta: float) -> void:
	var jumper: KinematicBody2D = get_node_or_null("GameObjects/Jumper")
	if jumper == null:
		return
	if jumper.position.y < highest_y:
		highest_y = jumper.position.y
	$Camera2D.position.y = highest_y + camera_y_offset


func _physics_process(_delta: float) -> void:
	var view_size = get_viewport_rect().size
	var view_bottom_y = $Camera2D.global_position.y + $Camera2D.offset.y + view_size.y / 2

	for child in $GameObjects.get_children():
		if child.position.y > view_bottom_y + PLATFORM_OFFSCREEN_OFFSET:
			child.queue_free()

	generate_chunks()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("pause_escape"):
		# TODO - add pause screen
		var error = get_tree().change_scene("res://states/MainMenu/MainMenu.tscn")
		assert(not error)


func generate_chunks() -> void:
	var view_size = get_viewport_rect().size
	var view_top_y = $Camera2D.global_position.y + $Camera2D.offset.y - view_size.y / 2

	while view_top_y - PLATFORM_OFFSCREEN_OFFSET < next_chunk_spawn_y:
		var chunk_info := CHUNK_TABLE[randi() % CHUNK_TABLE.size()] as Array
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
