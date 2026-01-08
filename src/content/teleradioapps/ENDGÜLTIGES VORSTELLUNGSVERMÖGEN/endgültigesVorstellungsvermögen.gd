extends TeleradioContent

const APP_ID := "EndgültigesVorstellungsvermögen"
@export var data : Node

var final_boss : bool = false # lazy implementation, need a proper pass on enemy casting
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
	data = $Data

func start_battle():
	hide_everything()
	stop_all_music()
	$Battles/BattleScene.show()
	$Audio/Music/MusicBattle.play()
	$Battles.battle_state = 1 # set battle state to START

func end_battle():
	hide_everything()
	stop_all_music()
	$Map.show()
	$Map/ButtonSelection.show()
	$Audio/Music/MusicOverworld.play()
	os.input.connect_to(os.input.just_pressed_b1, button_menu)

func button_menu():
	state = STATES.MENU

func title_stage():
	hide_everything()
	stop_all_music()
	$MainMenu.show()
	$Audio/Music/MusicTitleScreen.play()

	os.input.connect_to(os.input.just_pressed_b2, start_new_game)
	os.input.connect_to(os.input.just_pressed_b3, exit_game)

func continue_game():
	print("Continue")

func start_new_game(): # need to 
	hide_everything()
	stop_all_music()
	# reposition character, reset function here
	state = STATES.OVERWORLD

func exit_game():
	os.quit_app()

#Utility------------------------------------------------
func hide_everything():
	os.input.disconnect_all_buttons()
	$MainMenu.hide()
	$Map.hide()
	$Map/ButtonSelection.hide()
	$Battles/BattleScene.hide()

func stop_all_music():
	for m in $Audio/Music.get_children():
		m.stop()
