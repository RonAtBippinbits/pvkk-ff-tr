extends Node2D

var lifetime := 0.0

@onready var outline = $Outline

func _ready():
	$ExplosionParticle.restart()
	$ExplosionSprite.rotation = randf()*TAU
	var t := create_tween()
	t.tween_callback($ExplosionSprite.hide).set_delay(0.1)

func _physics_process(delta):
	if lifetime > 5.0:
		queue_free()
	lifetime += delta
	modulate.a = ease(abs(5.0-lifetime)/5.0, 4.3)
	outline.clear_points()
	var slice:float = TAU/32.0
	outline.width = 20.0 / global_scale.x
	for i in 32:
		outline.add_point(Vector2.RIGHT.rotated(float(i)*slice)*ease(lifetime*0.5, 0.9)*14.0)
	
