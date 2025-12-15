extends Line2D

var following_projectile : Node2D
var add_point_tick := 0


func _ready():
	width = 2.0 / global_scale.x


func decay():
	following_projectile = null
	set_physics_process(false)
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 6.0)
	t.tween_callback(queue_free)


func _physics_process(delta):
	if add_point_tick < 5:
		add_point_tick += 1
		return
	add_point_tick = 0
	if following_projectile:
		add_point(following_projectile.position)
		if get_point_count() > 200:
			remove_point(0)
