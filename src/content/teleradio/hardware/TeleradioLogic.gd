extends Node
class_name TeleradioLogic
## Class handling communication between the [TeleradioOS] and the [TeleradioHardware].

signal ring_start ## Connected on ready to the TeleradioHardware class
signal ring_stop ## Connected on ready to the TeleradioHardware class
signal load_sound_start ## Connected on ready to the TeleradioHardware class
signal load_sound_stop ## Connected on ready to the TeleradioHardware class

@export var _DebugLog:TextEdit

@export var ButtonOption1:Node ## Reference to hardware Button 1 on the Teleradio
@export var ButtonOption2:Node ## Reference to hardware Button 2 on the Teleradio
@export var ButtonOption3:Node ## Reference to hardware Button 3 on the Teleradio
@export var ButtonOption4:Node ## Reference to hardware Button 4 on the Teleradio
@export var Joystick:Node ## Reference to hardware Joystick on the Teleradio
@export var _TeleradioAudioPlayerLeft:Node
@export var _TeleradioAudioPlayerRight:Node

var _input_processor : TeleradioInputProcessor
var _version := 0.1
var _framerate_counter := 10.0
var _limit_framerate := true
var _debug_log_text := []
var framerate := 1.0/30.0 ## The Teleradios display framerate, this should be set via the [method TeleradioOS.set_framerate].

@export var tos : TeleradioOS ## Reference to the [TeleradioOS].
@export var _teleradio_input : TeleradioInput
@export var _audio : TeleradioAudio
@export var _hardware : TeleradioHardware

@onready var _teleradio_viewport : SubViewport = $TeleradioViewport


func _enter_tree():
	_scan_for_apps()
	tos.set_input(_teleradio_input)
	tos.audio = _audio
	tos.teleradio_logic = self
	_hardware.input = _teleradio_input
	_audio.audio_player_left = _TeleradioAudioPlayerLeft
	_audio.audio_player_right = _TeleradioAudioPlayerRight

func _ready():
	DeviceValidator.assert_hit_button(ButtonOption1)
	DeviceValidator.assert_hit_button(ButtonOption2)
	DeviceValidator.assert_hit_button(ButtonOption3)
	DeviceValidator.assert_hit_button(ButtonOption4)
	tos.load_sound_started.connect(_on_load_sound_started)
	tos.load_sound_stopped.connect(_on_load_sound_stopped)

func _process(delta):
	if _limit_framerate:
		if _framerate_counter > framerate:
			_framerate_counter = 0.0
			_teleradio_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		else:
			_framerate_counter += delta

func _input(event: InputEvent) -> void:
	if tos.forward_input_to_app:
		_teleradio_viewport.push_input(event)

func _scan_for_apps():
	_dir_contents("res://content/teleradioapps/")

func _dir_contents(path:String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				_dir_contents(path.path_join(file_name))
			else:
				if file_name == "TeleradioInstallFile.gd":
					var new_software = load(path.path_join(file_name)).new()
					if new_software.has_method("teleradio_autoinstall"):
						new_software.teleradio_autoinstall()
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

## Called by the Teleradio seat to start a local [InputProcessor].
func start_forward_input(processor_path:String):
	_input_processor = load(processor_path).new()
	_input_processor.integrate(self)
	_input_processor.teleradio_logic = self

## Stopping the local [InputProcessor] after getting up from the seat.
func stop_forward_input():
	_input_processor.desintegrate()
	_input_processor = null

## This can be used inside the DevKit to print debug messages to the log below the screen.
func info(message:String, source:Node=null):
	var new_line := ""
	if source:
		new_line = "%s: %s\n" % [source, message]
	else:
		new_line = "%s\n" % message
	
	if _DebugLog:
		_debug_log_text.append(new_line)
		if _debug_log_text.size() > 30:
			_debug_log_text.pop_front()
		var string := ""
		for s in _debug_log_text:
			string += s + "\n"
		_DebugLog.text = string
		_DebugLog.scroll_vertical = _DebugLog.get_line_count()
	else:
		print(new_line)

func _on_clear_log_button_pressed():
	if _DebugLog:
		_DebugLog.text = ""

## Start the Teleradio Ringtone.
func ring_begin():
	ring_start.emit()

## Stop the Teleradio Ringtone.
func ring_end():
	ring_stop.emit()

## Disable the Teleradio viewport rendering - this is called by a Visibility Notifier
func viewport_disable():
	$TeleradioViewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	$TeleradioViewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER

## Enable the Teleradio viewport rendering - this is called by a Visibility Notifier
func viewport_enable():
	$TeleradioViewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	$TeleradioViewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS

## Used by [TeleradioHardware] to get a reference to the viewport texture.
func get_texture() -> ViewportTexture:
	return $TeleradioViewport.get_texture()

func _on_load_sound_started() -> void:
	load_sound_start.emit()

func _on_load_sound_stopped() -> void:
	load_sound_stop.emit()

## This sets the Teleradios volume, should be controlled by a dial.
func set_volume(value):
	_audio.set_volume(value)

## This sets the Teleradios bitcrush effect and is only used here in the DevKit.
func set_bitcrush(value):
	_audio.set_bitcrush(value)
	
## This method enables or disables the button pressing sounds of the buttons on the Teleradio.
func set_play_button_sounds(value:bool):
	_teleradio_input.set_play_button_sounds(value)
