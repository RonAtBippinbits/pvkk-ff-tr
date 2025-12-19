extends Area2D

@export var root : Node # make sure it's assigned in main scene
@export var character : Node
@export var place_type1: String = "empty"
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
	match place_type1:
		"empty":
			print("type not defined")
		"castle":
			$PlaceUI/Dialogue/Text.text = "Do you want to rest in coneria castle to fully recover?"
			$PlaceUI/Choice/Yes.grab_focus()
			print("c")
		"village":
			$PlaceUI/Dialogue/Text.text = "Do you want to rest here to fully recover?"
			$PlaceUI/Choice/Yes.grab_focus()
		"dungeon":
			# trigger boss fight here
			print("b")

func _on_yes_button_down() -> void:
	$PlaceUI/Dialogue.hide() 
	$PlaceUI/Choice.hide()
	match place_type1:
		"empty":
			print("type not defined")
		"castle":
			await resting()
		"village":
			await resting()
		"dungeon":
			# trigger boss fight here
			print("b")
	character.block_moving = false

func resting():
	await fade_out_in()
	for c in character_group.get_children():
		c.revive()
		c.recover()

func _on_no_button_down() -> void:
		$PlaceUI/Dialogue.hide() 
		$PlaceUI/Choice.hide()
		character.block_moving = false

func _process(delta: float) -> void:
	if abs(root.os.input.joy_axis.y) <= 0.35:
		axis_locked = false
	if !root.os.input.joy_buttonA_down:
		A_locked = false
	if character.block_moving == true:
		handle_ui_selection()

func handle_ui_selection():
	var buttons := $PlaceUI/Choice.get_children()
	if root.os.input.joy_axis.y <= -0.4 && !axis_locked:  # Up
		ui_index = max(ui_index - 1, 0)
		update_ui_focus(buttons)
		axis_locked = true
	if root.os.input.joy_axis.y >= 0.4 && !axis_locked:  # Down
		ui_index = min(ui_index + 1, buttons.size() - 1)
		update_ui_focus(buttons)
		axis_locked = true
	if root.os.input.joy_buttonA_down and !A_locked:  # Select
		buttons[ui_index].emit_signal("button_down")
		A_locked = true

func update_ui_focus(buttons: Array[Node]):
	for i in range(buttons.size()):
		if i == ui_index:
			buttons[i].grab_focus()
		else:
			buttons[i].release_focus()

func fade_out_in():
	$PlaceUI/Fade.modulate.a = 0
	$PlaceUI/Fade.show()  
	var tween := create_tween()
	tween.tween_property($PlaceUI/Fade, "modulate:a", 1, 0.6)
	tween.tween_property($PlaceUI/Fade, "modulate:a", 0, 0.6)
	await tween.finished
	$PlaceUI/Fade.hide()
