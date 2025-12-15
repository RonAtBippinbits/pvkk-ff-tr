extends Node2D

var lifetime := 0.0

@onready var outline = $Outline
@onready var debug_draw = $DebugDraw

func _ready():
	var t := create_tween()
	t.tween_callback($DebugDraw.hide).set_delay(0.2)

func _physics_process(delta):
	if lifetime > 12.0:
		queue_free()
	lifetime += delta
	modulate.a = ease(abs(12.0-lifetime)/12.0, 0.3)
	outline.clear_points()
	var slice:float = TAU/8.0
	outline.width = 1.0 / global_scale.x
	debug_draw.scale = Vector2.ONE / global_scale.x
	for i in 8:
		outline.add_point(Vector2.RIGHT.rotated(float(i)*slice)*ease(lifetime*0.5, 0.3)*1.5)
	
