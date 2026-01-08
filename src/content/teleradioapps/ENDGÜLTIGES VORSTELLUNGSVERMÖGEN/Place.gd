extends Area2D

@export var root : Node # make sure it's assigned in main scene
@export var place_type: String = "empty"

func _on_body_entered(body: Node2D) -> void:
	if body.name != "PlayableCharacter":
		return
	root.Map.entered_place(place_type)
