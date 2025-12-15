extends Node2D

var speed = 20 

func _process(delta):
	position.x += speed * delta

func _ready():
	$Area2D.area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	if area.is_in_group("Killzone"):
		queue_free()
