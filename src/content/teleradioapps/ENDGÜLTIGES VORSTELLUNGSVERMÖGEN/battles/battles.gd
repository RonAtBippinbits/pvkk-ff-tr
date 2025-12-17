extends Node2D

@export var root : Node # make sure it's assigned in main scene

@onready var enemy_group = $BattleScene/enemy_group
@onready var enemies: Array = []
var enemy_index: int = 0 
@onready var character_group = $BattleScene/character_group
@onready var characters: Array = []
var character_index: int = 0 
@onready var choice : Node = %Choice
var ui_index : int = 0
var A_locked
var B_locked
var axis_locked

var action_queue: Array[Node] = []

enum BATTLESTATE { DEFAULT, START, PLAYER_CHOICE, PLAYER_TURN, ENEMY_TURN, WIN, GAME_OVER }
var _battle_state: BATTLESTATE = BATTLESTATE.DEFAULT
var battle_state: BATTLESTATE:
	get:
		return _battle_state
	set(value):
		if value != _battle_state:
			var previous = _battle_state
			_battle_state = value
			_on_state_changed(previous, value)

func _on_state_changed(previous, new):
	enemies = enemy_group.get_children()
	characters = character_group.get_children()
	match new:
		BATTLESTATE.START:
			print("BattleState.START")
			prepare_battle()
		BATTLESTATE.PLAYER_CHOICE:
			print("BattleState.PLAYER_CHOICE")
			if action_queue.size() == characters.size():
				unfocus_ui(choice.get_children())
				evaluate_action_queue(action_queue, battle_state)
			else: 
				$BattleScene/Choice/Attack.grab_focus()
		BATTLESTATE.PLAYER_TURN:
			enemies[0].show_focus()
			print("BattleState.PLAYER_TURN")
		BATTLESTATE.ENEMY_TURN:
			print("BattleState.ENEMY_TURN")
			enemy_turn()
		BATTLESTATE.WIN:
			print("BattleState.WIN")
			root.state = root.STATES.OVERWORLD
		BATTLESTATE.GAME_OVER:
			print("BattleState.GAME_OVER")
			# return to title 

func prepare_battle():
	
	characters = character_group.get_children()
	enemies = enemy_group.get_children()

	battle_state = BATTLESTATE.PLAYER_CHOICE

func enemy_turn():
	for e in enemies:
		action_queue.append(characters.pick_random())
	evaluate_action_queue(action_queue, battle_state)

var is_busy
func evaluate_action_queue(stack, current_state):
	reset_focus(enemies)
	reset_focus(characters)
	is_busy = true
	for i in stack: 
		if not is_instance_valid(i):
			continue
		i.take_damage(2)
		await get_tree().create_timer(1).timeout
	action_queue.clear()
	is_busy = false
	if battle_state == BATTLESTATE.PLAYER_CHOICE:
		battle_state = BATTLESTATE.ENEMY_TURN
	elif battle_state == BATTLESTATE.ENEMY_TURN:
		battle_state = BATTLESTATE.PLAYER_CHOICE

func _process(delta):
	if root.state != root.STATES.BATTLE:
		return
	if enemies.size() == 0:
		battle_state = BATTLESTATE.WIN
	handle_input()
#Input handling ----------------------------------
func handle_input():
	if abs(root.os.input.joy_axis.y) <= 0.35:
		axis_locked = false
	if !root.os.input.joy_buttonA_down:
		A_locked = false
	if !root.os.input.joy_buttonB_down:
		B_locked = false
	if battle_state == BATTLESTATE.PLAYER_CHOICE && !is_busy:
		handle_ui_selection()
	elif battle_state == BATTLESTATE.PLAYER_TURN && !is_busy:
		handle_enemy_selection()

func handle_ui_selection():
	var buttons := choice.get_children()
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
		enemy_index = 0
		enemies[enemy_index].show_focus()
		A_locked = true

func update_ui_focus(buttons: Array[Node]):
	for i in range(buttons.size()):
		if i == ui_index:
			buttons[i].grab_focus()
		else:
			buttons[i].release_focus()

func unfocus_ui(buttons: Array[Node]):
	for b in buttons:
		b.release_focus()

func handle_enemy_selection():
	if root.os.input.joy_axis.y <= -0.4 and !axis_locked:  # Up
		if enemy_index > 0:
			switch_focus(enemies, enemy_index, enemy_index - 1)
			enemy_index -= 1
			axis_locked = true
	if root.os.input.joy_axis.y >= 0.4 and !axis_locked:  # Down
		if enemy_index < enemies.size() - 1:
			switch_focus(enemies, enemy_index, enemy_index + 1)
			enemy_index += 1
			axis_locked = true
	if root.os.input.joy_buttonA_down and !A_locked :  # Confirm
		action_queue.append(enemies[enemy_index])
		enemy_index = 0
		reset_focus(enemies)
		battle_state = BATTLESTATE.PLAYER_CHOICE
		A_locked = true

#Buttons----------------------------------
func _on_attack_button_down() -> void:
	battle_state = BATTLESTATE.PLAYER_TURN

func _on_special_button_down() -> void:
	print("special not implemented")
	pass #Implement specials here

func _on_run_button_down() -> void:
	reset_focus(enemies)
	root.state = root.STATES.OVERWORLD

#Utility----------------------------------
func switch_focus(group: Array[Node], x, y):
	group[x].hide_focus()
	group[y].show_focus()

func reset_focus(group: Array[Node]):
	for n in group:
		n.hide_focus()
