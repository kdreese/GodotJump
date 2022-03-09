extends KinematicBody2D


signal game_over


const MOVE_SPEED = 300.0
const GRAVITY := 800.0
const JETPACK_GRAVITY := 200.0
const BOUNCE_SPEED := -650.0
const TERMINAL_VELOCITY := 1000.0
const JETPACK_DURATION := 2.0
const JETPACK_SPEED := -900.0
const SPRING_SPEED := -1000.0

var _gravity := GRAVITY
var _velocity := Vector2(0, 0)
var jetpack_timer := 0.0

onready var extents := ($CollisionShape2D.shape as RectangleShape2D).extents
onready var bounds := get_viewport_rect().size


func _process(delta: float) -> void:
	$Body/Inside.texture_rotation += delta


func _physics_process(delta: float) -> void:
	_velocity.x = Input.get_axis("move_left", "move_right") * MOVE_SPEED
	if jetpack_timer > 0:
		jetpack_timer -= delta
		if Global.sound_enabled:
			$JetpackSound.play()
		if jetpack_timer <= 0:
			_gravity = GRAVITY
			$JetpackParticles.emitting = false
			$JetpackSound.stop()

	_velocity.y += _gravity * delta
	_velocity.y = min(_velocity.y, TERMINAL_VELOCITY)
	_velocity = move_and_slide(_velocity, Vector2.UP)
	if is_on_floor():
		$AnimationPlayer.play("bounce")
		if get_last_slide_collision().collider.is_in_group("spring"):
			_velocity.y = SPRING_SPEED
			get_last_slide_collision().collider.get_node("AnimationPlayer").play("spring")
			if Global.sound_enabled:
				$SpringJumpSound.play()
		else:
			_velocity.y = BOUNCE_SPEED
			if Global.sound_enabled:
				$NormalJumpSound.play()

	if position.x < -bounds.x / 2 - extents.x:
		position.x += bounds.x + (2 * extents.x)
	if position.x >= bounds.x / 2 + extents.x:
		position.x -= bounds.x + (2 * extents.x)


func die() -> void:
	emit_signal("game_over")
	queue_free()


func _on_PowerupDetectionArea_area_entered(area: Node) -> void:
	if area.is_in_group("jetpack"):
		area.queue_free()
		jetpack_timer = JETPACK_DURATION
		_velocity.y = JETPACK_SPEED
		_gravity = JETPACK_GRAVITY
		$JetpackParticles.emitting = true


func _on_EnemyDetectionArea_body_entered(_body: Node) -> void:
	die()


func _on_EnemyDetectionArea_area_entered(_area: Area2D) -> void:
	die()
