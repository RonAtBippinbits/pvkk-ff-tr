extends CharacterBody2D

@export var root : Node # make sure it's assigned in main scene
var character_direction : Vector2
var block_moving : bool = false

func _physics_process(delta: float):
	if root.state == root.STATES.OVERWORLD:
		if !block_moving:
			movement()
		animate()

func movement():
	character_direction = root.os.input.joy_axis
	if character_direction != Vector2.ZERO:
		if abs(character_direction.x) > abs(character_direction.y):
			character_direction.y = 0
		else:
			character_direction.x = 0
		character_direction = character_direction.normalized()
		velocity = character_direction.normalized() * 32
		move_and_slide()

func animate():
	if block_moving  && $AnimatedSprite2D.is_playing() or character_direction == Vector2.ZERO && $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.stop()
		character_direction = Vector2.ZERO
		return
	if character_direction.x > 0:
		$AnimatedSprite2D.play("right")
	elif character_direction.x < 0:
		$AnimatedSprite2D.play("left")
	elif character_direction.y > 0:
		$AnimatedSprite2D.play("down")
	elif character_direction.y < 0:
		$AnimatedSprite2D.play("up")
