extends Area2D

@export var place_type1: String = "empty"

func _on_body_entered(body: Node2D) -> void:
	if body.name != "PlayableCharacter":
		return

	match place_type1:
		"empty":
			print("type not defined")
		"castle":
			#heal for now
			print("c")
		"dungeon":
			# trigger boss fight here
			print("b")
