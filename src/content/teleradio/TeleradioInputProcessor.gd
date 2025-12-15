extends InputProcessor
class_name TeleradioInputProcessor

var leftKeyDown := false
var rightKeyDown := false
var upKeyDown := false
var downKeyDown := false
var actionAKeyDown := false
var actionBKeyDown := false
var button1Down := false
var button2Down := false
var button3Down := false
var button4Down := false
var joyAxis := Vector2.ZERO

var teleradio_logic : TeleradioLogic
var debug_mode := false


func updateJoyAxis():
	joyAxis = Vector2(float(-int(leftKeyDown)+int(rightKeyDown)), float(-int(upKeyDown)+int(downKeyDown))).normalized()
	teleradio_logic.Joystick.JoystickAxis.set_absolute_value(joyAxis)
