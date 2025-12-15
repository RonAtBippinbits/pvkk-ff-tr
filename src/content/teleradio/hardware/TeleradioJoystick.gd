extends PanelContainer

@export var JoystickButtonA:Node
@export var JoystickButtonB:Node
@export var JoystickAxis:Node

func _ready():
	DeviceValidator.assert_hit_button(JoystickButtonA)
	DeviceValidator.assert_hit_button(JoystickButtonB)
	DeviceValidator.assert_numeric_input(JoystickAxis)
