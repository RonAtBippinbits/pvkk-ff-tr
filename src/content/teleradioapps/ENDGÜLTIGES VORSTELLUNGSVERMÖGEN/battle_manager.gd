extends Node2D

@onready var enemy_group = $enemy_group
@onready var character_group = $character_group

@onready var enemies: Array = []
@onready var characters: Array = []


var action_queue: Array = [] 

enum BattleState { DEFAULT, START, PLAYER_TURN, ENEMY_TURN, WIN, GAME_OVER }
var _battle_state: BattleState = BattleState.DEFAULT
var battle_state: BattleState:
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
		BattleState.START:
			prepare_battle()
		BattleState.PLAYER_TURN:
			print("BattleState.PLAYER_TURN")
			#show_choice()
		BattleState.ENEMY_TURN:
			print("BattleState.ENEMY_TURN")
			#enemy_turn()
		BattleState.WIN:
			print("BattleState.WIN")
			# end fight
		BattleState.GAME_OVER:
			print("BattleState.GAME_OVER")
			# return to title 

func prepare_battle():
	characters = character_group.get_children()
	enemies = enemy_group.get_children()
	battle_state = BattleState.PLAYER_TURN
