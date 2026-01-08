extends Area2D

@export var root : Node # make sure it's assigned in main scene
#@export var character : Node
@export var place_type: String = "empty"
@onready var character_group = $"../../Battles/BattleScene/character_group" 


func _on_body_entered(body: Node2D) -> void:
	if body.name != "PlayableCharacter":
		return
	root.Map.entered_place(place_type)

func resting(): # should be handled differently
	#await fade_out_in()
	for c in character_group.get_children():
		c.revive()
		c.recover()
