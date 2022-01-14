extends Node2D


const PLATFORM_DISAPPEAR_OFFSET := 100.0

onready var camera := ($Jumper/Camera2D as Camera2D)


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	var view_bottom_y = camera.global_position.y + camera.offset.y + (get_viewport_rect().size.y / 2)
	for platform in $Platforms.get_children():
		if platform.position.y > view_bottom_y + PLATFORM_DISAPPEAR_OFFSET:
			platform.queue_free()
