extends CharacterBody2D

@export var root : Node # make sure it's assigned in main scene
var character_direction : Vector2
var encounter_dist := 75
var last_encounter_pos := Vector2.ZERO

func _ready() -> void:
	last_encounter_pos = position

func _physics_process(delta: float):
	if root.state == root.STATES.OVERWORLD:
		movement()
		animate()
		encounter()
		if is_colliding():
			print("collided")

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

func is_colliding() -> bool:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision:
			return true
	return false

func encounter(): # iterate this implementation asap
	if position.distance_to(last_encounter_pos) >= encounter_dist:
		root.state = root.STATES.BATTLE
		last_encounter_pos = position
		encounter_dist = randi_range(50, 150)

func animate():
	if character_direction.x > 0:
		$AnimatedSprite2D.play("right")
	elif character_direction.x < 0:
		$AnimatedSprite2D.play("left")
	elif character_direction.y > 0:
		$AnimatedSprite2D.play("down")
	elif character_direction.y < 0:
		$AnimatedSprite2D.play("up")
	else:
		$AnimatedSprite2D.stop()
