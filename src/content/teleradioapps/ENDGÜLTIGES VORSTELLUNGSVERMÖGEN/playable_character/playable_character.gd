extends CharacterBody2D

@export var root : Node # make sure it's assigned in main scene
var character_direction : Vector2
var block_moving : bool = false
var encounter_dist := 110
var last_encounter_pos := Vector2.ZERO

func _ready() -> void:
	last_encounter_pos = position

func _physics_process(delta: float):
	if root.state == root.STATES.OVERWORLD:
		if !block_moving:
			movement()
			encounter()
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

func encounter(): # iterate this implementation asap
	if position.distance_to(last_encounter_pos) >= encounter_dist:
		root.state = root.STATES.BATTLE
		last_encounter_pos = position
		encounter_dist = randi_range(50, 150)

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
