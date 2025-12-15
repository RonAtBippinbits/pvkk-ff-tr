extends TeleradioContent

const APP_ID := "EndgültigesVorstellungsvermögen"

enum STATES {MENU, OVERWOLD, BATTLE, CUTSCENE}

var state:STATES = STATES.MENU

func _ready():
	state = STATES.MENU
	title_stage()

func title_stage():
	$Audio/Music/MusicTitleScreen.play()
	os.input.connect_to(os.input.just_pressed_b2, start_new_game)
	os.input.connect_to(os.input.just_pressed_b3, exit_game)

func continue_game():
	print("Continue")

func start_new_game():
	print("Start Game")
	$MainMenu.hide()
	# update menu buttons here

func exit_game():
	os.quit_app()
	
