extends Node2D

@export var root : Node # make sure it's assigned in main scene

@onready var enemy_group = $enemy_group
var enemy_index: int = 0 
@onready var character_group = $character_group
var character_index: int = 0 
@onready var choice : Node = %Choice
var A_locked
var B_locked
var axis_locked

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
	if root.state != root.STATES.BATTLE:
		return
	if battle_state == BATTLESTATE.PLAYER_TURN: # && can interact with menu
		# I should build some sort of input manager and move it there
		if abs(root.os.input.joy_axis.y) <= 0.35:
			axis_locked = false
		if !root.joy_buttonA_down:
			A_locked = false
		if !root.joy_buttonB_down:
			B_locked = false
		
		if root.os.input.joy_axis.y <= -0.4 && !axis_locked: # up
			if enemy_index > 0:
				enemy_index -= 1
				switch_focus(enemy_index, enemy_index + 1)
				axis_locked = true
		if root.os.input.joy_axis.y >= 0.4 && !axis_locked: #down
			if enemy_index < enemies.size() - 1:
				enemy_index += 1
				switch_focus(enemy_index, enemy_index - 1)
				axis_locked = true
		if root.joy_buttonA_down: # 
			action_queue.push_back(enemy_index) # need to determine in any way it's an enemy?
			if action_queue.size() != characters.size(): # Check for next char move
				print("action queue") #call action queue here
			enemy_index = 0 # reset index

func switch_focus(x,y):
	get_child(x).show_focus()
	get_child(y).hide_focus()
