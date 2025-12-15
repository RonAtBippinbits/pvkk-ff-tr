extends TeleradioContent

var scrolltween : Tween

func _ready():
	os.input.connect_to(os.input.just_pressed_b4, button_back_pressed)
	#
	#%Title.text = msg.title
	#%Sender.text = "Sender: " + msg.sender
	#%Message.text = msg.message

func button_back_pressed():
	os.quit_app()
