extends KinematicBody2D


const ROTATE_SPEED := 1.0
const OSCILLATION_AMPLITUDE = 10.0
const OSCILLATION_FREQUENCY = 2.0

var oscillation_time: float


func _ready() -> void:
	oscillation_time = randf() * TAU * OSCILLATION_FREQUENCY


func _process(delta: float) -> void:
	$CollisionShape2D/Sprite.rotate(ROTATE_SPEED * delta)
	$CollisionShape2D.position.y = OSCILLATION_AMPLITUDE * cos(oscillation_time * OSCILLATION_FREQUENCY)
	oscillation_time += delta
