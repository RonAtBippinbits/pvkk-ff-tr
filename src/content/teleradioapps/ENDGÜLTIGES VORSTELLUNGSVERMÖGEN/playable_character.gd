extends Sprite2D

@export var root : Node # make sure it's assigned in main scene
var character_direction : Vector2

func _physics_process(delta: float):
	if root.state == root.STATES.OVERWORLD:
		movement()
		
func movement():
	character_direction.x = root.os.input.joy_axis.x
	character_direction.y = root.os.input.joy_axis.y
	if character_direction != Vector2.ZERO:
		if abs(character_direction.x) > abs(character_direction.y):
			character_direction.y = 0
		else:
			character_direction.x = 0
		character_direction = character_direction.normalized()
		position += character_direction
