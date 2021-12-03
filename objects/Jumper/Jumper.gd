extends KinematicBody2D


const MOVE_SPEED = 150.0
const GRAVITY := 350.0
const BOUNCE_SPEED := -450.0

var _velocity := Vector2(0, 0)


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	_velocity.x = Input.get_axis("move_left", "move_right") * MOVE_SPEED
	_velocity.y += GRAVITY * delta
	_velocity = move_and_slide(_velocity, Vector2.UP)
	if is_on_floor():
		_velocity.y = BOUNCE_SPEED
