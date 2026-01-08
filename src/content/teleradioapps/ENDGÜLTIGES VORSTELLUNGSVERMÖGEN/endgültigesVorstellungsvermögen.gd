extends TeleradioContent

const APP_ID := "EndgültigesVorstellungsvermögen"

@onready var Data : Node = $Data
@onready var MainMenu : Node = $MainMenu
@onready var Map : Node = $Map
@onready var Character : Node = $Map/PlayableCharacter
@onready var CharacterGroup : Node = $Battles/BattleScene/character_group
@onready var Battles : Node = $Battles

enum STATES {LAUNCH, MENU, OVERWORLD, BATTLE, CUTSCENE}
var _state: STATES = STATES.LAUNCH
var state:STATES:
	get:
		return _state
	set(value):
		if value != _state:
			var previous = _state
			_state = value
			_on_state_changed(previous, value)
func _on_state_changed(previous, new):
	match new:
		STATES.MENU:
			print("STATES.MENU")
			title_stage()
		STATES.OVERWORLD:
			print("STATES.OVERWORLD")
			end_battle()
		STATES.BATTLE:
			print("STATES.BATTLE")
			start_battle()
		STATES.CUTSCENE:
			print("STATES.CUTSCENE")

func _ready():
	state = STATES.MENU

func start_battle():
	hide_everything()
	stop_all_music()
	#$Battles/BattleScene.show()
	$Audio/Music/MusicBattle.play()
	Battles.battle_state = 1 # set battle state to START

func end_battle():
	hide_everything()
	stop_all_music()
	Map.show()
	Character.block_moving = false
	$Audio/Music/MusicOverworld.play()
	update_button_selection(1, "Main Menu")
	os.input.connect_to(os.input.just_pressed_b1, button_show_menu)

func title_stage():
	hide_everything()
	stop_all_music()
	MainMenu.show()
	$Audio/Music/MusicTitleScreen.play()
	update_button_selection(1, "Start Game")
	os.input.connect_to(os.input.just_pressed_b1, button_new_game)
	update_button_selection(2, "Exit Game")
	os.input.connect_to(os.input.just_pressed_b2, exit_game)
	Battles.final_boss = false 

#region ButtonSelection
func button_new_game():
	hide_everything()
	stop_all_music()
	# reposition character, reset function here
	state = STATES.OVERWORLD

func continue_game():
	print("Continue") #not implemented right now

func exit_game():
	os.quit_app()

func button_show_menu():
	state = STATES.MENU
#endregion

#region Utility
func hide_everything():
	MainMenu.hide()
	Map.hide()
	$Battles/BattleScene.hide()
	os.input.disconnect_all_buttons()
	for b in $ButtonSelection.get_children():
		b.hide()

func update_button_selection(button_index: int, text : String):
	$ButtonSelection.get_child(button_index - 1).text = text
	$ButtonSelection.get_child(button_index - 1).show()

func stop_all_music():
	for m in $Audio/Music.get_children():
		m.stop()
#endregion
