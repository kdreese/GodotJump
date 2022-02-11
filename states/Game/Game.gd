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

var next_chunk_spawn_y: float

onready var camera := ($GameObjects/Jumper/Camera2D as Camera2D)


func _ready() -> void:
	randomize()
	next_chunk_spawn_y = ($GameObjects/ChunkStart as Position2D).position.y
	$GameObjects/ChunkStart.queue_free()


func _physics_process(_delta: float) -> void:
	var view_size = get_viewport_rect().size
	var view_top_y = camera.global_position.y + camera.offset.y - view_size.y / 2
	var view_bottom_y = view_top_y + view_size.y

	for child in $GameObjects.get_children():
		if child.position.y > view_bottom_y + PLATFORM_OFFSCREEN_OFFSET:
			child.queue_free()

	while view_top_y - PLATFORM_OFFSCREEN_OFFSET < next_chunk_spawn_y:
		var chunk_info := CHUNK_TABLE[randi() % CHUNK_TABLE.size()] as Array
		spawn_chunk("res://templates/platform_chunks/%s.tscn" % chunk_info[0], chunk_info[1])
		var next_chunk_end := $GameObjects/ChunkEnd as Position2D
		next_chunk_spawn_y = next_chunk_end.position.y
		next_chunk_end.free()


func spawn_chunk(chunk_path: String, randomize_x: bool = false):
	var chunk := load(chunk_path).instance() as Node2D
	for child in chunk.get_children():
		var position = child.position
		var view_width := get_viewport_rect().size.x
		if randomize_x:
			position.x = rand_range(-PLATFORM_RANGE, PLATFORM_RANGE)
		position.x += view_width / 2
		position.y += next_chunk_spawn_y
		chunk.remove_child(child)
		$GameObjects.add_child(child)
		child.position = position
	chunk.queue_free()
