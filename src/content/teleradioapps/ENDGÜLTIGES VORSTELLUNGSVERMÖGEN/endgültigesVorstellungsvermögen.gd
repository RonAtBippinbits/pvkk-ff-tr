extends TeleradioContent

const APP_ID := "EndgültigesVorstellungsvermögen"

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
#Gameflow------------------------------------------------
func _ready():
	state = STATES.MENU

func _on_state_changed(previous, new):
	match new:
		STATES.MENU:
			title_stage()
		STATES.OVERWORLD:
			print("State")
		STATES.BATTLE:
			start_battle()
		STATES.CUTSCENE:
			print("cutscene")



func start_battle():
	$MainMenu.hide()
	$Maps/ButtonSelection.show()
	$Maps/PlayableCharacter.show()
	$Maps/Overworld.show()
	stop_all_music()
	$Audio/Music/MusicBattle.play()
	#$BattleScene/BattleManager.start_the_battle()

#MainMenu------------------------------------------------
func title_stage():
	for n in $Maps.get_children(): 
		n.hide()
	stop_all_music()
	$Audio/Music/MusicTitleScreen.play()
	$MainMenu.show()
	os.input.disconnect_all_buttons()
	os.input.connect_to(os.input.just_pressed_b2, start_new_game)
	os.input.connect_to(os.input.just_pressed_b3, exit_game)

func continue_game():
	print("Continue")

func start_new_game():
	$MainMenu.hide()
	$Maps/ButtonSelection.show()
	$Maps/PlayableCharacter.show()
	$Maps/Overworld.show()
	stop_all_music()
	
	$Audio/Music/MusicOverworld.play()
	os.input.disconnect_all_buttons()
	os.input.connect_to(os.input.just_pressed_b1, title_stage)
	state = STATES.OVERWORLD

func exit_game():
	os.quit_app()

#Utility------------------------------------------------
func stop_all_music():
	for m in $Audio/Music.get_children():
		m.stop()
