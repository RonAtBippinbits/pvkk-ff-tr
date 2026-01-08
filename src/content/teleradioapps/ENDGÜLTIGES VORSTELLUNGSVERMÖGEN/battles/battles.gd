extends Node2D

@export var root : Node # make sure it's assigned in main scene
var entity = preload("res://content/teleradioapps/ENDGÜLTIGES VORSTELLUNGSVERMÖGEN/battles/entity.tscn")

@onready var enemy_group = $BattleScene/enemy_group
@onready var enemies: Array = []
var enemy_index: int = 0 

@onready var character_group = $BattleScene/character_group
@onready var characters: Array = []
var character_index: int = 0 

@onready var battle_log_text = $BattleScene/BattleLog/Text
@onready var choice : Node = %Choice
var ui_index : int = 0

var A_locked
var B_locked
var axis_locked
var is_busy = false
#---------------------------------------------------------------------------------------------------------
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
			prepare_battle_scene()
	#BATTLE LOOP
		BATTLESTATE.PLAYER_CHOICE:
			if action_queue.size() == characters.size() && action_queue.size() > 0:
				evaluate_action_queue(action_queue, battle_state)
			else: 
				$BattleScene/Choice/Attack.grab_focus()
				update_description_log("attack", true)
		BATTLESTATE.PLAYER_TURN:
			enemies[0].show_focus()
			update_description_log(characters[character_index].entity_type + " will attack " + enemies[enemy_index].entity_type, false)
		BATTLESTATE.ENEMY_TURN:
			enemy_turn()
	#BATTLE RESULTS
		BATTLESTATE.WIN:
			update_description_log("won", true) 
			root.stop_all_music()
			$Fanfare.play()
			for c in characters:
				if !c.character_dead:
					c.play(c.entity_type + "_won")
		BATTLESTATE.GAME_OVER:
			update_description_log("game_over", true) 
#---------------------------------------------------------------------------------------------------------
func _process(delta):
	if root.state != root.STATES.BATTLE:
		return
	if enemies.size() == 0 && battle_state != BATTLESTATE.WIN:
		battle_state = BATTLESTATE.WIN
	if characters.size() == 0 && battle_state != BATTLESTATE.GAME_OVER:
		battle_state = BATTLESTATE.GAME_OVER
	handle_input()

#region Battle logic
func create_enemy_cast(enemy_count: int, enemy_types: Array):
	var start_pos := Vector2(100, 105)
	var spacing_x := 120
	var spacing_y := 90
	var columns := 2
	for i in range(enemy_count):
		var enemy_key = enemy_types.pick_random()
		var enemy = entity.instantiate()
		enemy.load_entity_data(enemy_key)
		enemy_group.add_child(enemy)
		var column = i % columns
		var row = i / columns
		enemy.position = Vector2(
			start_pos.x + column * spacing_x,
			start_pos.y + row * spacing_y
		)

func final_boss(): # lazy implementation, need a proper pass on enemy casting
	var enemy = entity.instantiate()
	enemy.load_entity_data("e_boss_1")
	enemy_group.add_child(enemy)
	enemy.position = Vector2(200, 200)
	enemy.scale = Vector2(enemy.scale.x * 1.5, enemy.scale.y * 1.5)
	enemy.get_node("Focus").texture = null

func prepare_battle_scene():
	if root.final_boss:
		final_boss()
	else:
		var possible_enemies = ["goblin_1", "skeleton_1", "spider_1"]
		create_enemy_cast(randi_range(3, 5), possible_enemies)
	characters = character_group.get_children()
	enemies = enemy_group.get_children()
	reset_entity_focus(enemies)
	ui_index = 0
	battle_state = BATTLESTATE.PLAYER_CHOICE
	
	$BattleScene.show()

func enemy_turn():
	character_index = 0
	if enemies.size() == 0:
		return
	for e in enemies:
		queue_attack(e, characters.pick_random(), e.attack, character_group)
	evaluate_action_queue(action_queue, battle_state)

func result_won():
	for c in characters:
		c.revive()
		c.play(c.entity_type )
	cleanup_battle_scene()
	$Fanfare.stop()
	root.state = root.STATES.OVERWORLD

func result_game_over():
	root.state = root.STATES.MENU
	for c in characters:
		c.revive()
		c.recover()
	cleanup_battle_scene()

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
func queue_attack(attacker: Node, target: Node, damage: int, group: Node): 
	var action = { "attacker": attacker, "target": target, "damage": damage, "group": group} 
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
	enemies = enemy_group.get_children()
	characters = character_group.get_children()
	var target = action["target"]
	if not is_instance_valid(target):
		target = null
	var validated_target = get_valid_target(target, action["group"])
	if validated_target == null:
		return
	validated_target.take_damage(action["damage"])
	#attacker.play_attack_animation() <- should implement that later!
	update_description_log(action["attacker"].entity_type + " deals " + str(action["damage"]) + " damage to " + validated_target.entity_type + ".", false)
	await get_tree().create_timer(1).timeout

func get_valid_target(original_target: Object, group: Node):
	if original_target != null and not original_target.character_dead:
		return original_target
	var valid_targets := []
	for t in group.get_children():
		if is_instance_valid(t) and not t.character_dead:
			valid_targets.append(t)
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
	elif battle_state == BATTLESTATE.WIN:
		if root.os.input.joy_buttonA_down and !A_locked:
			result_won()
			A_locked = true
	elif battle_state == BATTLESTATE.GAME_OVER:
		if root.os.input.joy_buttonA_down and !A_locked:
			result_game_over()
			A_locked = true

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
			switch_entity_focus(enemies, enemy_index, enemy_index - 1)
			enemy_index -= 1
			axis_locked = true
	if root.os.input.joy_axis.y >= 0.4 and !axis_locked:  # Down
		if enemy_index < enemies.size() - 1:
			switch_entity_focus(enemies, enemy_index, enemy_index + 1)
			enemy_index += 1
			axis_locked = true
	if root.os.input.joy_buttonA_down and !A_locked :  # Confirm
		queue_attack(characters[character_index], enemies[enemy_index], characters[character_index].attack, enemy_group)
		character_index += 1
		enemy_index = 0
		reset_entity_focus(enemies)
		battle_state = BATTLESTATE.PLAYER_CHOICE
		A_locked = true

func update_description_log(msg: String, is_key: bool):
	if is_key:
		if root.Data.text_data_battles.has(msg):
			battle_log_text.text = root.Data.text_data_battles[msg]["text"]
	else:
		battle_log_text.text = msg

func switch_entity_focus(group: Array[Node], x, y):
	group[x].hide_focus()
	group[y].show_focus()
	update_description_log(characters[character_index].entity_type + " will attack " + enemies[enemy_index].entity_type, false)

func reset_entity_focus(group: Array[Node]):
	if group.size() == 0:
		return
	for n in group:
		n.hide_focus()
#endregion

#region Button functions
func _on_attack_button_down() -> void:
	battle_state = BATTLESTATE.PLAYER_TURN

func _on_special_button_down() -> void:
	print("special not implemented")
	pass #Implement specials here

func _on_run_button_down() -> void:
	reset_entity_focus(enemies)
	cleanup_battle_scene()
	for c in characters:
		c.revive()
	root.state = root.STATES.OVERWORLD

func _on_attack_focus_entered() -> void:
	update_description_log("attack", true)
	pass # Replace with function body.

func _on_special_focus_entered() -> void:
	update_description_log("special_" + characters[character_index].entity_type, true)

func _on_run_focus_entered() -> void:
	update_description_log("run", true)
#endregion
