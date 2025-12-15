extends Node

@export var unit_scene : PackedScene

func _ready():
	#%Timer.wait_time = randf_range(1.0, 3.0)
	%Timer.start()
	%Timer.timeout.connect(_on_spawn_timer_timeout)
	
	pass

func _on_spawn_timer_timeout():
	spawn_unit()
	%Timer.wait_time = randf_range(1.0, 3.0)

func spawn_unit():
	var slots = get_children()
	var slot = slots.pick_random()
	var instance = unit_scene.instantiate()
	instance.position = slot.get_child(0).position # child 0 = Spawnpos
	slot.add_child(instance)
