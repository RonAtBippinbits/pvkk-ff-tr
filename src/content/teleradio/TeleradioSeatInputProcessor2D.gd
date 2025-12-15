extends TeleradioInputProcessor
class_name TeleradioInputProcessor2D

func becameLeaf():
	notLeaf()

func notLeaf():
	leftKeyDown = false
	rightKeyDown = false
	upKeyDown = false
	downKeyDown = false
	updateJoyAxis()
	actionAKeyDown = false
	actionBKeyDown = false
	button1Down = false
	button2Down = false
	button3Down = false
	button4Down = false

func keyEvent(event) -> bool:
	var play_button_sounds:bool = teleradio_logic.tos.input.should_play_button_sounds()
	#region Joystick Movement
	if pressed(event, "move_left"):
		leftKeyDown = true
		if debug_mode:
			teleradio_logic.info("move_left down", self)
		updateJoyAxis()
	elif pressed(event, "move_right"):
		rightKeyDown = true
		if debug_mode:
			teleradio_logic.info("move_right down", self)
		updateJoyAxis()
	elif pressed(event, "move_forward"):
		upKeyDown = true
		if debug_mode:
			teleradio_logic.info("move_forward down", self)
		updateJoyAxis()
	elif pressed(event, "move_back"):
		downKeyDown = true
		if debug_mode:
			teleradio_logic.info("move_back down", self)
		updateJoyAxis()
	elif released(event, "move_left"):
		leftKeyDown = false
		if debug_mode:
			teleradio_logic.info("move_left up", self)
		updateJoyAxis()
	elif released(event, "move_right"):
		rightKeyDown = false
		if debug_mode:
			teleradio_logic.info("move_right up", self)
		updateJoyAxis()
	elif released(event, "move_forward"):
		upKeyDown = false
		if debug_mode:
			teleradio_logic.info("move_forward up", self)
		updateJoyAxis()
	elif released(event, "move_back"):
		downKeyDown = false
		if debug_mode:
			teleradio_logic.info("move_back up", self)
		updateJoyAxis()
	#endregion
	#region Teleradio Buttons 1-4
	elif pressed(event, "view_1"):
		button1Down = true
		if debug_mode:
			teleradio_logic.info("button_1 down", self)
		teleradio_logic.ButtonOption1._on_button_down(play_button_sounds)
	elif pressed(event, "view_2"):
		button2Down = true
		if debug_mode:
			teleradio_logic.info("button_2 down", self)
		teleradio_logic.ButtonOption2._on_button_down(play_button_sounds)
	elif pressed(event, "view_3"):
		button3Down = true
		if debug_mode:
			teleradio_logic.info("button_3 down", self)
		teleradio_logic.ButtonOption3._on_button_down(play_button_sounds)
	elif pressed(event, "view_4"):
		button4Down = true
		if debug_mode:
			teleradio_logic.info("button_4 down", self)
		teleradio_logic.ButtonOption4._on_button_down(play_button_sounds)
	elif released(event, "view_1"):
		button1Down = false
		if debug_mode:
			teleradio_logic.info("button_1 up", self)
		teleradio_logic.ButtonOption1._on_button_up(play_button_sounds)
	elif released(event, "view_2"):
		button2Down = false
		if debug_mode:
			teleradio_logic.info("button_2 up", self)
		teleradio_logic.ButtonOption2._on_button_up(play_button_sounds)
	elif released(event, "view_3"):
		button3Down = false
		if debug_mode:
			teleradio_logic.info("button_3 up", self)
		teleradio_logic.ButtonOption3._on_button_up(play_button_sounds)
	elif released(event, "view_4"):
		button4Down = false
		if debug_mode:
			teleradio_logic.info("button_4 up", self)
		teleradio_logic.ButtonOption4._on_button_up(play_button_sounds)
	#endregion
	#region Joystick Buttons A+B
	elif pressed(event, "interaction_mode"):
		actionAKeyDown = true
		if debug_mode:
			teleradio_logic.info("interaction_mode down", self)
		teleradio_logic.Joystick.JoystickButtonA._on_button_down(play_button_sounds)
	elif released(event, "interaction_mode"):
		actionAKeyDown = false
		if debug_mode:
			teleradio_logic.info("interaction_mode up", self)
		teleradio_logic.Joystick.JoystickButtonA._on_button_up(play_button_sounds)
	elif pressed(event, "alt_action"):
		actionBKeyDown = true
		if debug_mode:
			teleradio_logic.info("alt_action down", self)
		teleradio_logic.Joystick.JoystickButtonB._on_button_down(play_button_sounds)
	elif released(event, "alt_action"):
		actionBKeyDown = false
		if debug_mode:
			teleradio_logic.info("alt_action up", self)
		teleradio_logic.Joystick.JoystickButtonB._on_button_up(play_button_sounds)
	#endregion
	elif pressed(event, "use"): # Stand Up
		return false
	return true
