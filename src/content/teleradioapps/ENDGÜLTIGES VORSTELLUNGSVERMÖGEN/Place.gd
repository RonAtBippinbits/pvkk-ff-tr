extends Area2D

@export var root : Node # make sure it's assigned in main scene
@export var character : Node
@export var place_type: String = "empty"
@onready var character_group = $"../../Battles/BattleScene/character_group" 

var ui_index : int = 0
var A_locked
var axis_locked
var is_busy = false

func _on_body_entered(body: Node2D) -> void:
	if body.name != "PlayableCharacter":
		return

	$PlaceUI/Dialogue.show()
	$PlaceUI/Choice.show()
	character.block_moving = true
	ui_index = 0

	axis_locked = true
	A_locked = true

	update_dialogue(place_type, true)

	await get_tree().process_frame

	ui_index = 0
	var buttons := $PlaceUI/Choice.get_children()
	buttons[ui_index].grab_focus()

#region Input handling 
func _process(delta):
	if abs(root.os.input.joy_axis.y) <= 0.35:
		axis_locked = false

	if not root.os.input.joy_buttonA_down:
		A_locked = false

	if character.block_moving and $PlaceUI/Choice.visible and not axis_locked:
		handle_ui_selection()

func handle_ui_selection():
	var buttons := $PlaceUI/Choice.get_children()
	if root.os.input.joy_axis.y <= -0.4 and not axis_locked:  # Up
		ui_index = max(ui_index - 1, 0)
		update_ui_focus(buttons)
		axis_locked = true
	elif root.os.input.joy_axis.y >= 0.4 and not axis_locked:  # Down
		ui_index = min(ui_index + 1, buttons.size() - 1)
		update_ui_focus(buttons)
		axis_locked = true
	if root.os.input.joy_buttonA_down and not A_locked:  # Select
		buttons[ui_index].emit_signal("button_down")
		A_locked = true

func update_ui_focus(buttons: Array[Node]):
	for i in range(buttons.size()):
		if i == ui_index:
			buttons[i].grab_focus()

func update_dialogue(msg: String, is_key: bool):
	if is_key:
		if root.data.text_data_places.has(msg):
			$PlaceUI/Dialogue/Text.text = root.data.text_data_places[msg]["text"]
	else:
		$PlaceUI/Dialogue/Text.text = msg
#endregion

#region Button functions
func _on_yes_button_down() -> void:
	$PlaceUI/Dialogue.hide() 
	$PlaceUI/Choice.hide()
	match place_type:
		"empty":
			print("type not defined")
		"castle":
			await resting()
		"village":
			await resting()
		"dungeon":
			root.final_boss = true 
			root.state = root.STATES.BATTLE
			print("b")
	character.block_moving = false

func _on_no_button_down() -> void:
		$PlaceUI/Dialogue.hide() 
		$PlaceUI/Choice.hide()
		character.block_moving = false
#endregion

func resting(): # should be handled differently
	await fade_out_in()
	for c in character_group.get_children():
		c.revive()
		c.recover()

func fade_out_in():
	$PlaceUI/Fade.modulate.a = 0
	$PlaceUI/Fade.show()  
	var tween := create_tween()
	tween.tween_property($PlaceUI/Fade, "modulate:a", 1, 0.6)
	tween.tween_property($PlaceUI/Fade, "modulate:a", 0, 0.6)
	await tween.finished
	$PlaceUI/Fade.hide()
