extends TileMapLayer

@export var root : Node # make sure it's assigned in main scene

var ui_index : int = 0
var A_locked
var axis_locked
var is_busy = false

var place_type: String 

@export var encounter_dist_min := 50
@export var encounter_dist_max := 150

var last_encounter_pos := Vector2.ZERO
var next_encounter_dist := 0

func _ready():
	await get_tree().process_frame
	last_encounter_pos = root.Character.global_position
	next_encounter_dist = randi_range(encounter_dist_min, encounter_dist_max)

func _process(delta):
	if root.state != root.STATES.OVERWORLD:
		return
	if root.Character.block_moving:
		return
	check_encounter_distance()
	#Input
	if abs(root.os.input.joy_axis.y) <= 0.35:
		axis_locked = false
	if not root.os.input.joy_buttonA_down:
		A_locked = false
	if $PlaceUI/Choice.visible and not axis_locked:
		handle_ui_selection()

#region Ecounters
func check_encounter_distance():
	if root.Character.velocity.length() == 0:
		return
	var pos = root.Character.global_position
	if pos.distance_to(last_encounter_pos) >= next_encounter_dist:
		trigger_encounter()

func trigger_encounter():
	last_encounter_pos = root.Character.global_position
	next_encounter_dist = randi_range(encounter_dist_min, encounter_dist_max)
	root.Character.block_moving = true
	root.state = root.STATES.BATTLE
#endregion

#region Places
func entered_place(type : String):
	place_type = type
	$PlaceUI/Dialogue.show()
	$PlaceUI/Choice.show()
	root.Character.block_moving = true
	update_dialogue(place_type, true)
	
	ui_index = 0
	axis_locked = true
	A_locked = true
	await get_tree().process_frame
	var buttons := $PlaceUI/Choice.get_children()
	buttons[ui_index].grab_focus()

func fade_out_in():
	$PlaceUI/Fade.modulate.a = 0
	$PlaceUI/Fade.show()  
	var tween := create_tween()
	tween.tween_property($PlaceUI/Fade, "modulate:a", 1, 0.6)
	tween.tween_property($PlaceUI/Fade, "modulate:a", 0, 0.6)
	await tween.finished
	$PlaceUI/Fade.hide()

func resting():
	await fade_out_in()
	for c in root.CharacterGroup.get_children():
		c.revive()
		c.recover()
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
			root.Battles.final_boss = true 
			root.state = root.STATES.BATTLE
	root.Character.block_moving = false

func _on_no_button_down() -> void:
		$PlaceUI/Dialogue.hide() 
		$PlaceUI/Choice.hide()
		root.Character.block_moving = false
#endregion

#region Input handling 
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
		if root.Data.text_data_places.has(msg):
			$PlaceUI/Dialogue/Text.text = root.Data.text_data_places[msg]["text"]
	else:
		$PlaceUI/Dialogue/Text.text = msg
#endregion
