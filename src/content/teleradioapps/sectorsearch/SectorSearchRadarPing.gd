extends Area2D

signal found_enemy

const RADAR_WAVE_SPEED := 40.0

var slowdown := 1.0
var found_enemies := {}

@onready var shape:CircleShape2D = $CollisionShape2D.shape
@onready var outline = $Outline


func _physics_process(delta):
	shape.radius += delta*RADAR_WAVE_SPEED*slowdown
	if shape.radius > 220.0:
		queue_free()
	modulate.a = 0.5+slowdown*0.5
	outline.width = clamp(slowdown*4.0, 0.0, 1.0)*20.0 / global_scale.x
	slowdown = clamp(slowdown-delta*0.15, 0.2, 1.0)
	outline.clear_points()
	var radius = shape.radius
	var slice:float = TAU/64.0
	for i in 64:
		outline.add_point(Vector2.RIGHT.rotated(float(i)*slice)*radius)


func _on_area_entered(area):
	if found_enemies.has(area):
		return
	found_enemies[area] = true
	found_enemy.emit(area.position)
