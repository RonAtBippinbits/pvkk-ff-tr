extends Node2D

@export var root : Node # make sure it's assigned in main scene

@onready var enemy_group = $enemy_group
var enemy_index: int = 0 
@onready var character_group = $character_group
var character_index: int = 0 
@onready var choice : Node

@onready var enemies: Array = []
@onready var characters: Array = []


var action_queue: Array = [] 

enum BATTLESTATE { DEFAULT, START, PLAYER_TURN, ENEMY_TURN, WIN, GAME_OVER }
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
	print("battle_state changed!")
	match new:
		BATTLESTATE.START:
			prepare_battle()
		BATTLESTATE.PLAYER_TURN:
			print("BattleState.PLAYER_TURN")
			#show_choice()
		BATTLESTATE.ENEMY_TURN:
			print("BattleState.ENEMY_TURN")
			#enemy_turn()
		BATTLESTATE.WIN:
			print("BattleState.WIN")
			# end fight
		BATTLESTATE.GAME_OVER:
			print("BattleState.GAME_OVER")
			# return to title 

func prepare_battle():
	characters = character_group.get_children()
	enemies = enemy_group.get_children()
	battle_state = BATTLESTATE.PLAYER_TURN

func _process(delta: float):
	if root.state != root.STATES.BATTLE: # make sure player is allowed to do someting
		return


		# Next step here should be a simple implementation of choice UI

	if battle_state == BATTLESTATE.PLAYER_TURN: 
		if Input.is_action_just_pressed("ui_up"): # <---------------- need teleradio input here!!!
			if enemy_index > 0:
				enemy_index -= 1
				switch_focus(enemy_index, enemy_index + 1)
		if Input.is_action_just_pressed("ui_down"): #
			if enemy_index < enemies.size() - 1:
				enemy_index += 1
				switch_focus(enemy_index, enemy_index - 1)
		if Input.is_action_just_pressed("ui_accept"): # 
			action_queue.push_back(enemy_index) # need to determine in any way it's an enemy?
			if action_queue.size() != characters.size():
				#show_choice()
				emit_signal("next_character")
#		if action_queue.size() == characters.size() && processing_actions == false:
#			evaluate_action_queue(action_queue, state) # proceed to enemy turn here
			enemy_index = 0 # reset index

func switch_focus(x,y):
	get_child(x).show_focus()
	get_child(y).hide_focus()
