extends Node2D


const Platform = preload("res://objects/Platform/Platform.tscn")

const PLATFORM_OFFSCREEN_OFFSET := 100.0
const PLATFORM_SPAWN_DISTANCE := 200.0	# Vertical distance between platform spawns
const PLATFORM_RANGE = 250.0	# The max horizontal range from the center of the viewport the platforms will vary

onready var next_platform_spawn_y := ($Platforms/FirstPlatform as Node2D).position.y - PLATFORM_SPAWN_DISTANCE
onready var camera := ($Jumper/Camera2D as Camera2D)


func _ready() -> void:
	randomize()


func _physics_process(_delta: float) -> void:
	var view_size = get_viewport_rect().size
	var view_top_y = camera.global_position.y + camera.offset.y - view_size.y / 2
	var view_bottom_y = view_top_y + view_size.y

	for platform in $Platforms.get_children():
		if platform.position.y > view_bottom_y + PLATFORM_OFFSCREEN_OFFSET:
			platform.queue_free()

	while view_top_y - PLATFORM_OFFSCREEN_OFFSET < next_platform_spawn_y:
		spawn_platform(Vector2(view_size.x / 2 + rand_range(-PLATFORM_RANGE, PLATFORM_RANGE), next_platform_spawn_y))
		next_platform_spawn_y -= PLATFORM_SPAWN_DISTANCE


func spawn_platform(position):
	var platform = Platform.instance()
	platform.position = position
	$Platforms.add_child(platform)
