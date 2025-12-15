extends TeleradioContent
## A basic Teleradio App boilerplate

func _ready() -> void:
	os.input.connect_button1(hello_world)
	os.input.connect_button4(os.quit_app)

func hello_world():
	os.teleradio_logic.info("hello world in the tdk debug box", self)
	print("hello world")
