extends Node
class_name TeleradioInput
## Everything related to input and buttons for the Teleradio is handled in this class.
## 
## For the default four buttons located directly on the Teleradio, a [code]signal[/code] 
## is emitted when the button is pushed and a [code]bool[/code] which is [code]true[/code] as
## long as the button is held down.[br][br]
## The two Joystick buttons have an additional [code]signal[/code] for button release.[br][br]
## A scene with some good examples on how to use this class is located here:[br]
## [u]res://content/teleradio/software/os/apps/inputdebugger/InputDebugger.tscn[/u][br][br]
## Typical usage in [TeleradioContent] can look like this:
## [codeblock]
## func _ready():
##     # there are helper functions to directly connect buttons 1-4
##     os.input.connect_button1(on_just_pressed_button_1)
##     # 'connect_to' takes a signal as the first parameter, it is suited for iteration.
##     var signals := [os.input.just_pressed_b1, os.input.just_pressed_b2]
##     for i in signals.size():
##         os.input.connect_to(signals[i], on_just_pressed_button.bind(i))
## 
## func on_just_pressed_button(button_id:int):
##     print("Player just pressed Button %s on the Teleradio" % button_id)
## 
## func on_just_pressed_button_1():
##     print("Player just pressed Button 2 on the Teleradio")
##     # Disconnecting a button is either done by disconnecting single buttons
##     os.input.disconnect_from(os.input.just_pressed_b1, on_just_pressed_button_1)
##     # or by disconnecting all buttons
##     os.input.disconnect_all_buttons()
## [/codeblock]

signal input_received(s:StringName) ## This signal is emitted on any interaction of Teleradio hardware buttons.

#region Teleradio Buttons 1-4
signal just_pressed_b1
signal just_pressed_b2
signal just_pressed_b3
signal just_pressed_b4
var button1_down := false
var button2_down := false
var button3_down := false
var button4_down := false
#endregion

#region Joystick Axis and Buttons A+B
signal just_pressed_joyA
signal just_released_joyA
signal just_pressed_joyB
signal just_released_joyB
var joy_buttonA_down := false
var joy_buttonB_down := false
var joy_axis := Vector2.ZERO
#endregion

var _play_button_sounds := true
var _connected_hardware := {}
var _logic : TeleradioLogic


func _enter_tree() -> void:
	assert(owner is TeleradioLogic, "TeleradioInput owner is not TeleradioLogic!")
	_connect_to_hardware(owner)

func _connect_to_hardware(assigned_logic:TeleradioLogic):
	_logic = assigned_logic
	_connected_hardware[just_pressed_b1] = _logic.ButtonOption1
	_logic.ButtonOption1.hit.connect(_set_button1_down.bind(true))
	_logic.ButtonOption1.release.connect(_set_button1_down.bind(false))
	_connected_hardware[just_pressed_b2] = _logic.ButtonOption2
	_logic.ButtonOption2.hit.connect(_set_button2_down.bind(true))
	_logic.ButtonOption2.release.connect(_set_button2_down.bind(false))
	_connected_hardware[just_pressed_b3] = _logic.ButtonOption3
	_logic.ButtonOption3.hit.connect(_set_button3_down.bind(true))
	_logic.ButtonOption3.release.connect(_set_button3_down.bind(false))
	_connected_hardware[just_pressed_b4] = _logic.ButtonOption4
	_logic.ButtonOption4.hit.connect(_set_button4_down.bind(true))
	_logic.ButtonOption4.release.connect(_set_button4_down.bind(false))
	_connected_hardware[just_pressed_joyA] = _logic.Joystick.JoystickButtonA
	_connected_hardware[just_released_joyA] = _logic.Joystick.JoystickButtonA
	_logic.Joystick.JoystickButtonA.hit.connect(_set_joy_buttonA_down.bind(true))
	_logic.Joystick.JoystickButtonA.release.connect(_set_joy_buttonA_down.bind(false))
	_connected_hardware[just_pressed_joyB] = _logic.Joystick.JoystickButtonB
	_connected_hardware[just_released_joyB] = _logic.Joystick.JoystickButtonB
	_logic.Joystick.JoystickButtonB.hit.connect(_set_joy_buttonB_down.bind(true))
	_logic.Joystick.JoystickButtonB.release.connect(_set_joy_buttonB_down.bind(false))
	_logic.Joystick.JoystickAxis.value_changed.connect(_set_joy_axis)

## Returns a [Dictionary] or all input connections. Used by [TeleradioHardware] to control the button highlights.
func get_buttons_connected_dict() -> Dictionary:
	var connections := {}
	for input_signal:Signal in _connected_hardware:
		var has_connection:bool = not input_signal.get_connections().is_empty()
		connections[_connected_hardware[input_signal]] = has_connection
	return connections

func _set_button1_down(v:bool):
	if v and not button1_down:
		just_pressed_b1.emit()
	if v:
		input_received.emit(&"button1")
	button1_down = v

func _set_button2_down(v:bool):
	if v and not button2_down:
		just_pressed_b2.emit()
	if v:
		input_received.emit(&"button2")
	button2_down = v

func _set_button3_down(v:bool):
	if v and not button3_down:
		just_pressed_b3.emit()
	if v:
		input_received.emit(&"button3")
	button3_down = v

func _set_button4_down(v:bool):
	if v and not button4_down:
		just_pressed_b4.emit()
	if v:
		input_received.emit(&"button4")
	button4_down = v

func _set_joy_buttonA_down(v:bool):
	if v and not joy_buttonA_down:
		just_pressed_joyA.emit()
	if not v and joy_buttonA_down:
		just_released_joyA.emit()
	if v:
		input_received.emit(&"joy_buttonA")
	joy_buttonA_down = v

func _set_joy_buttonB_down(v:bool):
	if v and not joy_buttonB_down:
		just_pressed_joyB.emit()
	if not v and joy_buttonB_down:
		just_released_joyB.emit()
	if v:
		input_received.emit(&"joy_buttonB")
	joy_buttonB_down = v

func _set_joy_axis(v:Vector2):
	if v.length() > 0.0:
		input_received.emit(&"joy_axis")
	joy_axis = v

## Disconnects one signal to one callable. Takes [param s] as the signal to connect to [param c] a callable.
## Example how to use this from [TeleradioContent]:
## [codeblock]
##     os.input.connect_to(os.input.just_pressed_joyA, on_just_pressed_joyA)
## [/codeblock]
func connect_to(s:Signal, c:Callable, flags:=0):
	if _connected_hardware.has(s) and not s.is_connected(c):
		s.connect(c, flags)

## Disconnects one signal from one callable. Takes [param s] as the signal to disconnect from [param c] a connected callable.
## Example how to use this from [TeleradioContent]:
## [codeblock]
##     os.input.disconnect_from(os.input.just_pressed_joyA, on_just_pressed_joyA)
## [/codeblock]
func disconnect_from(s:Signal, c:Callable):
	if _connected_hardware.has(s) and s.is_connected(c):
		s.disconnect(c)

## Disconnects all connected buttons.[br]
## [color=yellow]Important:[/color] this method is called by [TeleradioOS] when quitting [TeleradioContent].
## There is no need to call this manually when exiting your application.
func disconnect_all_buttons():
	for s:Signal in _connected_hardware.keys():
		for c in s.get_connections():
			c.signal.disconnect(c.callable)

## Saves the interrupted apps input connections and [member play_button_sound] setting.[br]
## [color=yellow]Important:[/color] This is handled by [TeleradioOS] and must not be handled by [TeleradioContent].
func save_app_input(restoration_dict:Dictionary):
	restoration_dict.clear()
	restoration_dict["signals"] = {}
	for input_signal:Signal in _connected_hardware:
		var connections:Array = input_signal.get_connections()
		if not connections.is_empty():
			restoration_dict.signals[input_signal] = connections
	restoration_dict["play_button_sounds"] = _play_button_sounds

## Restores the interrupted apps input connections and [member play_button_sound] setting.[br]
## [color=yellow]Important:[/color] This is handled by [TeleradioOS] and must not be handled by [TeleradioContent].
func restore_app_input(restoration_dict:Dictionary):
	if not restoration_dict.has("signals"):
		return
	for input_signal:Signal in restoration_dict.signals:
		var connections:Array = restoration_dict.signals[input_signal]
		for connection in connections:
			connect_to(connection.signal, connection.callable, connection.flags)
	_play_button_sounds = restoration_dict["play_button_sounds"]
	restoration_dict.clear()

## Helper function to directly connect Button 1. Takes [param c] for the [Callable] that the signal will be connected to.
func connect_button1(c:Callable):
	if _connected_hardware.has(just_pressed_b1) and not just_pressed_b1.is_connected(c):
		just_pressed_b1.connect(c)

## Helper function to directly connect Button 2. Takes [param c] for the [Callable] that the signal will be connected to.
func connect_button2(c:Callable):
	if _connected_hardware.has(just_pressed_b2) and not just_pressed_b2.is_connected(c):
		just_pressed_b2.connect(c)

## Helper function to directly connect Button 3. Takes [param c] for the [Callable] that the signal will be connected to.
func connect_button3(c:Callable):
	if _connected_hardware.has(just_pressed_b3) and not just_pressed_b3.is_connected(c):
		just_pressed_b3.connect(c)

## Helper function to directly connect Button 4. Takes [param c] for the [Callable] that the signal will be connected to.
func connect_button4(c:Callable):
	if _connected_hardware.has(just_pressed_b4) and not just_pressed_b4.is_connected(c):
		just_pressed_b4.connect(c)

## This method enables or disables the button pressing sounds of the buttons on the Teleradio.
func set_play_button_sounds(_play_button_sounds:=true):
	self._play_button_sounds = _play_button_sounds

## Returns if button sounds should be played.
func should_play_button_sounds() -> bool:
	return _play_button_sounds
