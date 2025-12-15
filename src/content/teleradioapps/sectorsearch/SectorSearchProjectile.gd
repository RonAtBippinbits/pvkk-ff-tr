extends Area2D

signal impact
signal remove_projectile

var dir := Vector2.RIGHT
var speed := 10.0
var start_position := position

func _physics_process(delta):
	position += dir*delta*speed
	rotation = dir.angle()
	if position.distance_to(start_position) > 240.0:
		remove_projectile.emit(self)


func _on_area_entered(area):
	area.queue_free()
	impact.emit(position)
	remove_projectile.emit(self)
