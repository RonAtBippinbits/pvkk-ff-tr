extends Interactable
class_name Useable

signal used
signal combined
signal combined_from_hand

@export_multiline var hint = "Press [E] to\ndrink Tea"
@export var icon : Texture
@export var item_id : String
@export var combines_with : Array[String]
@export var combines_with_from_hand : Array[String]

var block_use := false

func use(_player):
	used.emit()

func combine(_player, item:Useable):
	combined.emit()

func combine_from_hand(_player, item:Useable):
	combined.emit()

func can_combine(item:Useable):
	return not block_use and combines_with.has(item.item_id)

func can_combine_from_hand(item:Useable):
	return combines_with_from_hand.has(item.item_id)

func combine_with(player, item:Useable):
	if not can_combine(item):
		return
	combine(player, item)

func combine_with_from_hand(player, item:Useable):
	if not can_combine_from_hand(item):
		return
	combine_from_hand(player, item)

func has_combinables():
	return not combines_with.is_empty()

func left_click_progress(_player, _combination_object, delta):
	pass

func no_input():
	pass
