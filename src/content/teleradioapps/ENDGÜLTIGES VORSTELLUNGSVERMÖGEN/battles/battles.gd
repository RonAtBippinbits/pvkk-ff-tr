extends Node2D

@export var root : Node # make sure it's assigned in main scene

var entity = preload("res://content/teleradioapps/ENDGÜLTIGES VORSTELLUNGSVERMÖGEN/battles/entity.tscn")
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
var is_busy = false

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
	#BATTLE SETUP
		BATTLESTATE.START:
			print("BattleState.START")
			prepare_battle_scene()
	#BATTLE LOOP
		BATTLESTATE.PLAYER_CHOICE:
			print("BattleState.PLAYER_CHOICE")
			if action_queue.size() == characters.size() && action_queue.size() > 0:
				evaluate_action_queue(action_queue, battle_state)
			else: 
				$BattleScene/Choice/Attack.grab_focus()
		BATTLESTATE.PLAYER_TURN:
			print("BattleState.PLAYER_TURN")
			enemies[0].show_focus()
		BATTLESTATE.ENEMY_TURN:
			print("BattleState.ENEMY_TURN")
			enemy_turn()
	#BATTLE RESULTS
		BATTLESTATE.WIN:
			print("BattleState.WIN")
			result_won()
		BATTLESTATE.GAME_OVER:
			print("BattleState.GAME_OVER")
			result_game_over()

func _process(delta):
	if root.state != root.STATES.BATTLE:
		return
	if enemies.size() == 0 && battle_state != BATTLESTATE.WIN:
		battle_state = BATTLESTATE.WIN
	if characters.size() == 0 && battle_state != BATTLESTATE.GAME_OVER:
		battle_state = BATTLESTATE.GAME_OVER
	handle_input()

#region Battle logic
func create_enemy_cast(enemy_count : int): #add an option to define which enemies are used
	for i in enemy_count:
		var entity_scene = entity.instantiate()
		entity_scene.load_enemy_data("goblin_1")
		enemy_group.add_child(entity_scene)
		entity_scene.position = Vector2 (160 + 10 * i, 145 + 80 * i)

func prepare_battle_scene():
	create_enemy_cast(3)
	characters = character_group.get_children()
	enemies = enemy_group.get_children()
	battle_state = BATTLESTATE.PLAYER_CHOICE

func enemy_turn():
	character_index = 0
	if enemies.size() == 0:
		return
	for e in enemies:
		queue_attack(e.attack, characters.pick_random())
		#action_queue.append(characters.pick_random())
	evaluate_action_queue(action_queue, battle_state)

func result_won():
	root.state = root.STATES.OVERWORLD
	cleanup_battle_scene()
	pass

func result_game_over():
	root.state = root.STATES.MENU
	for c in characters:
		c.revive()
		c.recover()
	cleanup_battle_scene()
	pass

func cleanup_battle_scene():
	for c in characters:
		if c.character_dead:
			c.revive()
	for e in enemies:
		e.health = 0 # to kill them
	action_queue.clear()
	# other states? reset values?
#endregion

#region Queue for attacks
var action_queue: Array = []
func queue_attack(damage: int, target: Node): 
	var action = { "target": target, "damage": damage } 
	action_queue.append(action)

func evaluate_action_queue(stack, current_state):
	unfocus_ui(choice.get_children())
	reset_entity_focus(enemies)
	reset_entity_focus(characters)
	is_busy = true
	for action in stack:
		await execute_action(action)
	action_queue.clear()
	is_busy = false
	var dead = 0
	for c in characters:
		if c.character_dead == true:
			dead += 1
	if dead == 3:
		battle_state = BATTLESTATE.GAME_OVER
		return
	if battle_state == BATTLESTATE.PLAYER_CHOICE:
		battle_state = BATTLESTATE.ENEMY_TURN
	elif battle_state == BATTLESTATE.ENEMY_TURN:
		battle_state = BATTLESTATE.PLAYER_CHOICE

func execute_action(action: Dictionary):
	var target = get_valid_target(action["target"])
	if target == null:
		return
	target.take_damage(action["damage"])
	await get_tree().create_timer(1).timeout

func get_valid_target(original_target: Node):
	if is_instance_valid(original_target) and not original_target.character_dead:
		return original_target #return the original target
	var group: Array
	if characters.has(original_target):
		group = characters
	else:
		group = enemies
	var valid_targets := []
	for n in group:
		if is_instance_valid(n) and not n.character_dead:
			valid_targets.append(n)
	if valid_targets.is_empty():
		return null # there is no valid target left
	return valid_targets.pick_random() # return an alternative legal target 
#endregion

#region Input handling 
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

func switch_entity_focus(group: Array[Node], x, y):
	group[x].hide_focus()
	group[y].show_focus()

func reset_entity_focus(group: Array[Node]):
	if group.size() == 0:
		return
	for n in group:
		n.hide_focus()

func handle_enemy_selection():
	if root.os.input.joy_axis.y <= -0.4 and !axis_locked:  # Up
		if enemy_index > 0:
			switch_entity_focus(enemies, enemy_index, enemy_index - 1)
			enemy_index -= 1
			axis_locked = true
	if root.os.input.joy_axis.y >= 0.4 and !axis_locked:  # Down
		if enemy_index < enemies.size() - 1:
			switch_entity_focus(enemies, enemy_index, enemy_index + 1)
			enemy_index += 1
			axis_locked = true
	if root.os.input.joy_buttonA_down and !A_locked :  # Confirm
		queue_attack(characters[character_index].attack, enemies[enemy_index])
		#action_queue.append(enemies[enemy_index])
		character_index += 1
		enemy_index = 0
		reset_entity_focus(enemies)
		battle_state = BATTLESTATE.PLAYER_CHOICE
		A_locked = true

#endregion

#region Button functions
func _on_attack_button_down() -> void:
	battle_state = BATTLESTATE.PLAYER_TURN

func _on_special_button_down() -> void:
	print("special not implemented")
	pass #Implement specials here

func _on_run_button_down() -> void:
	reset_entity_focus(enemies)
	for c in characters:
		c.revive()
	root.state = root.STATES.OVERWORLD
#endregion
