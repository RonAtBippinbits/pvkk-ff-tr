extends TeleradioContent

const APP_ID := "EndgültigesVorstellungsvermögen"

enum STATES {MENU, OVERWOLD, BATTLE, CUTSCENE}

var state:STATES = STATES.MENU

func title_stage():
	print("a")
