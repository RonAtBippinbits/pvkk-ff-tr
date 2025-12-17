extends AnimatedSprite2D

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

func movement():
	character_direction = root.os.input.joy_axis
	if character_direction != Vector2.ZERO:
		if abs(character_direction.x) > abs(character_direction.y):
			character_direction.y = 0
		else:
			character_direction.x = 0
		character_direction = character_direction.normalized()
		position += character_direction
		if position.distance_to(last_encounter_pos) >= encounter_dist:
			root.state = root.STATES.BATTLE
			last_encounter_pos = position
			encounter_dist = randi_range(50, 150)

func animate():
	if character_direction.x > 0:
		play("right")
	elif character_direction.x < 0:
		play("left")
	elif character_direction.y > 0:
		play("down")
	elif character_direction.y < 0:
		play("up")
	else:
		stop()
