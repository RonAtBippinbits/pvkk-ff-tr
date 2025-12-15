extends Area2D

signal reached_goal

var goal : Vector2
var speed := 1.0
var dir := Vector2.RIGHT

func _ready():
	dir = position.direction_to(goal)

func _physics_process(delta):
	position += dir*delta*speed
	rotation = dir.angle()
	if position.distance_to(goal) < 3.0:
		reached_goal.emit()
		set_physics_process(false)
