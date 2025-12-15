extends Node2D
class_name TeleradioOS
## The Operating System of the Teleradio.
## 
## This class acts as an interface between [TeleradioContent] and the Teleradio.
## It supplies utilities and interfaces to connect and control the Teleradio hardware.[br][br]
## [TeleradioInput] is used for input and buttons related things.[br]
## [TeleradioLogic] should only be used for debugging use cases.[br]
## [TeleradioFilesystem] is available to save files in the virtual filesystem of the Teleradio.[br][br]
## 
## It also offers some "flavor" functions to improve the experience of apps like adjusting the framerate
## or the bitcrush audio effect.[br][br]
## Typical usage in [TeleradioContent] can look like this:
## [codeblock]
## func _ready():
##     # lowering the framerate - a purely cosmetic effect
##     os.set_framerate(10)
##     # show a OS styled error message
##     os.show_error_message("Drillbert escaped!")
##     # request to quit your app
##     os.quit_app()


const _SCREENSAVER_TIMEOUT := 40.0
const _DEFAULT_FRAMERATE := 60
const _APP_SCREENSAVER := preload("res://content/teleradio/software/os/apps/screensaver/TeleradioContentScreensaver.tscn")
const ID_MAIN_MENU := "Main Menu"
const ID_MAIN_MENU_RESTRICTED := "Main Menu (Restricted)"

signal request_cartridge_eject ## Internal, do not connect or emit from applications.
signal cartridge_drive_block ## Internal, do not connect or emit from applications.
signal load_sound_started ## Internal, do not connect or emit from applications.
signal load_sound_stopped ## Internal, do not connect or emit from applications.
signal cartridge_load_started ## Internal, do not connect or emit from applications.
signal cartridge_load_stopped ## Internal, do not connect or emit from applications.
signal cartridge_busy_led_blocked ## Internal, do not connect or emit from applications.

@export var _app_slot : Node2D
@export var _loading_screen : Node2D
@export var _briefing_slot : Node
@export var filesystem : TeleradioFilesystem ## Reference to [TeleradioFilesystem], the virtual filesystem.

var _app_interrupted := false
var _interrupted_app_bitcrush := 1.0
var _interrupted_app_framerate := 30.0
var _interrupted_app_input_map : Dictionary
var _popup_app_input_map : Dictionary
var _screensaver := false
var _screensaver_timer := 0.0
var _current_app : TeleradioContent
var _current_os_app : TeleradioContent
var audio : TeleradioAudio ## Reference to [TeleradioAudio]. [color=yellow]Important:[/color] Do not set audio parameters via this reference from content.
var teleradio_logic : TeleradioLogic ## Reference to [TeleradioLogic]. Used to print debug messages from [TeleradioContent].
var input : TeleradioInput ## Reference to [TeleradioInput].
var forward_input_to_app := false ## If `forward_input_to_app` is true, all inputs from the Teleradio Logic are forwarded into the teleradio app viewport. Should be disabled in general

var _menu_selection := 0
var _current_menu := ID_MAIN_MENU

@onready var hide_when_app_running := [
	$Background, $MainMenu, $ButtonLabels
]

func _ready():
	set_framerate(_DEFAULT_FRAMERATE)
	await get_tree().process_frame
	_start_screensaver()

func _process(delta):
	if not (_current_app or _current_os_app):
		for c in hide_when_app_running:
			c.show()
		_screensaver_timer += delta
		if _screensaver_timer > _SCREENSAVER_TIMEOUT:
			_start_screensaver()
	else:
		for c in hide_when_app_running:
			c.hide()

func _interrupt_app(interrupt:bool):
	if interrupt and _current_app == null:
		return
	_app_interrupted = interrupt
	_current_app.process_mode = Node.PROCESS_MODE_DISABLED if _app_interrupted else Node.PROCESS_MODE_ALWAYS
	if _app_interrupted:
		cartridge_busy_led_blocked.emit(true)
		input.save_app_input(_interrupted_app_input_map)
		input.disconnect_all_buttons()
		_interrupted_app_bitcrush = audio.bitcrush_value
		_interrupted_app_framerate = teleradio_logic.framerate
		audio.set_bitcrush()
		set_framerate()
	else:
		cartridge_busy_led_blocked.emit(false)
		input.disconnect_all_buttons()
		input.restore_app_input(_interrupted_app_input_map)
		audio.set_bitcrush(_interrupted_app_bitcrush)
		teleradio_logic.framerate = _interrupted_app_framerate

func _open_new_content(id:String):
	if _is_content_app(id):
		var entry = GameWorld.teleradio_entries[id]
		entry.seen = true
		start_app(entry.scene)
	else:
		show_error_message("", _reset_after_error)

func _is_content_app(id) -> bool:
	return GameWorld.teleradio_entries.has(id)

func _prepare_os_content(path:String):
	loading_screen_stop()
	$MainMenu.hide()
	if _current_os_app:
		return
	if _screensaver:
		_quit_screensaver()
	if _current_app:
		_interrupt_app(true)
	_current_os_app = load(path).instantiate()
	_current_os_app.os = self

func _display_menu(id:String):
	id = try_hijack_menu_display(id)
	
	if not GameWorld.teleradio_menu_contents.has(id):
		_open_new_content(id)
		return
	_current_menu = id
	if not is_main_menu(_current_menu):
		_connect_back_button()
	else:
		_connect_back_to_screensaver()
		
	%Headline.text = id
	var menu_content := ""
	var i := 0
	for t in GameWorld.teleradio_menu_contents[id]:
		var unseen = _count_unseen_entries_in(t)
		if unseen > 0:
			t += "(%s)" % unseen
			
		if GameWorld.teleradio_entries.has(t) and not GameWorld.teleradio_entries[t].seen:
			t += " (new)"
		
		if i == _menu_selection:
			menu_content += "> " + t + "\n"
		else:
			menu_content += "  " + t + "\n"
		i += 1
	if i > 0:
		_connect_default_buttons()
	%Content.text = menu_content

func is_main_menu(id:String):
	return id == ID_MAIN_MENU or id == ID_MAIN_MENU_RESTRICTED

func try_hijack_menu_display(id:String) -> String:
	if id == ID_MAIN_MENU:
		var state = Data.of("mission.state")
		if state == CONST.MISSION_STATE_BRIEFING_DONE or state == CONST.MISSION_STATE_ACTIVE:
			id = ID_MAIN_MENU_RESTRICTED
		
	return id

func _connect_default_buttons():
	input.connect_to(input.just_pressed_b1, _button_select_pressed)
	input.connect_to(input.just_pressed_b2, _button_up_pressed)
	input.connect_to(input.just_pressed_b3, _button_down_pressed)

func _connect_back_to_screensaver():
	%ButtonLabels.label_4 = "Exit"
	%ButtonLabels.label_4_visible = true
	input.connect_to(input.just_pressed_b4, _button_back_pressed)

func _connect_back_button():
	%ButtonLabels.label_4 = "Back"
	%ButtonLabels.label_4_visible = true
	input.connect_to(input.just_pressed_b4, _button_back_pressed)

func _count_unseen_entries_in(id):
	var c := 0
	if GameWorld.teleradio_menu_contents.has(id):
		for x in GameWorld.teleradio_menu_contents[id]:
			if GameWorld.teleradio_entries.has(x) and not GameWorld.teleradio_entries[x].seen:
				c+=1
	return c

func _button_up_pressed():
	_menu_selection = wrapi(_menu_selection-1, 0, GameWorld.teleradio_menu_contents[_current_menu].size())
	_display_menu(_current_menu)

func _button_down_pressed():
	_menu_selection = wrapi(_menu_selection+1, 0, GameWorld.teleradio_menu_contents[_current_menu].size())
	_display_menu(_current_menu)

func _button_select_pressed():
	var old_selection = _menu_selection
	_menu_selection = 0
	var selected_content_id:String = GameWorld.teleradio_menu_contents[_current_menu][old_selection]
	if _is_content_app(selected_content_id):
		input.disconnect_all_buttons()
		_loading_screen.start_loading(1.0, true)
		await(_loading_screen.loading_finished)
		_display_menu(selected_content_id)
	else:
		input.disconnect_all_buttons()
		_loading_screen.start_loading()
		await(_loading_screen.loading_finished)
		_display_menu(selected_content_id)

func _reset_after_error():
	_loading_screen.start_loading()
	await(_loading_screen.loading_finished)
	_menu_selection = 0
	_display_menu(ID_MAIN_MENU)

func _button_back_pressed():
	if is_main_menu(_current_menu) and not _screensaver:
		await get_tree().process_frame
		_start_screensaver()
	else:
		input.disconnect_all_buttons()
		_loading_screen.start_loading()
		await(_loading_screen.loading_finished)
		_menu_selection = GameWorld.teleradio_menu_contents.keys().find(_current_menu)
		_display_menu(ID_MAIN_MENU)

func _received_input(_from:StringName):
	_screensaver_timer = 0.0

func _start_screensaver():
	if _current_app:
		return
	_current_app = _APP_SCREENSAVER.instantiate()
	_current_app.os = self
	_current_app.request_quit_screensaver.connect(_quit_screensaver)
	_screensaver = true
	_app_slot.add_child(_current_app)

func _quit_screensaver():
	if _screensaver:
		_screensaver = false
		quit_app()

## Start a Fail Call.[br]
## [color=yellow]Important:[/color] This is called by game logic and should not be called by an app.
func start_fail_call():
	_prepare_os_content("res://content/teleradio/software/os/apps/failstate/TeleradioContentFailstate.tscn")
	_briefing_slot.add_child(_current_os_app)

## Start a Briefing Call.[br]
## [color=yellow]Important:[/color] This is called by game logic and should not be called by an app.
func start_briefing(mission_id:String):
	_prepare_os_content("res://content/teleradio/software/os/apps/briefing/TeleradioContentBriefing.tscn")
	_current_os_app.briefing_mission_id = mission_id
	_briefing_slot.add_child(_current_os_app)

## Start a Debriefing Call.[br]
## [color=yellow]Important:[/color] This is called by game logic and should not be called by an app.
func start_debriefing():
	_prepare_os_content("res://content/teleradio/software/os/apps/briefing/TeleradioContentBriefing.tscn")
	_briefing_slot.add_child(_current_os_app)

## Start a loading screen.
func loading_screen_start(callback:Callable, loading_speed:=1.0, reset:=false):
	_loading_screen.start_loading(loading_speed, reset)
	_loading_screen.loading_finished.connect(callback, CONNECT_ONE_SHOT)

## Interrup/Stop the loading screen.
func loading_screen_stop():
	_loading_screen.stop_loading()

## This function is called by TeleradioLogic to set the TeleradioInput class.[br]
## [color=yellow]Important:[/color] This is called by TeleradioLogic and is not a function that should be called by an app.
func set_input(_input:TeleradioInput):
	input = _input
	input.input_received.connect(_received_input)

## Starting a new application (e.g. a game, an application).
func start_app(app:PackedScene, cartridge_content_resource:CartridgeContent=null, force_quit_app:=false):
	if _current_os_app:
		request_cartridge_eject.emit()
		return
	if _current_app:
		if force_quit_app:
			_screensaver = false
			quit_app()
			await get_tree().process_frame
		else:
			return
	$MainMenu.hide()
	input.disconnect_all_buttons()
	_current_app = app.instantiate()
	_current_app.cartridge_content = cartridge_content_resource
	_current_app.os = self
	_app_slot.add_child(_current_app)

## Request quitting the current application (e.g. a game, an application).[br]
## Calling with [param with_loading_screen][code] = true[/code] will show a loading screen before returning the the OS.
func quit_app(with_loading_screen:=false):
	forward_input_to_app = false
	audio.set_bitcrush()
	set_framerate()
	input.disconnect_all_buttons()
	_current_app.queue_free()
	_current_app = null
	if with_loading_screen:
		_loading_screen.start_loading(1.0, true)
		await(_loading_screen.loading_finished)
	$MainMenu.show()
	_display_menu(_current_menu)

## Request quitting the current os application (e.g. briefings).[br]
## [color=yellow]Important:[/color] This should not be called by normal Teleradio apps and is only used by applications from the PVKK base game.
func quit_os_app():
	if not _current_os_app:
		return
	audio.set_bitcrush()
	set_framerate()
	input.disconnect_all_buttons()
	_current_os_app.queue_free()
	_current_os_app = null
	_loading_screen.start_loading(1.0, true)
	await(_loading_screen.loading_finished)
	if _current_app:
		_interrupt_app(false)
	else:
		_start_screensaver()

## Show an error message in the OS.[br]
## The error message disconnects all inputs when showing the message and reconnects them on exit.[br]
## When the error message is closed, [param callable] is called.
func show_error_message(message:String="", callable:Callable=func():pass):
	input.save_app_input(_popup_app_input_map)
	input.disconnect_all_buttons()
	%ErrorMessageSfx.play()
	if message == "":
		message = "Error 862:\nFile not found or\nno access rights!"
	%ErrorMessage.hide()
	%ErrorMessage.text = message
	%ErrorPanel.position.y = 120.0
	var t := create_tween()
	t.set_parallel().tween_property(%ErrorPanel, "position:y", 80.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	t.tween_callback(%ErrorMessage.show).set_delay(0.2)
	%Error.show()
	input.connect_to(input.just_pressed_b4, %Error.hide)
	input.connect_to(input.just_pressed_b4, input.disconnect_all_buttons)
	input.connect_to(input.just_pressed_b4, input.restore_app_input.bind(_popup_app_input_map))
	input.connect_to(input.just_pressed_b4, callable)

## Use this to emulate a slowdown of the Teleradio.[br]
## [color=yellow]Important:[/color] This is a purely visual effect and does not have impact on [method  Node._process] or [method  Node._physics_process]
func set_framerate(framerate := _DEFAULT_FRAMERATE):
	teleradio_logic.framerate = 1.0/float(framerate)

## Start the ringtone of the Teleradio. To be used by calls.
func ring_begin():
	teleradio_logic.ring_begin()

## Stop the ringtone of the Teleradio. To be used by calls.
func ring_end():
	teleradio_logic.ring_end()

## Used by the filesystem to get the currently running apps ID.[br]
func get_app_name() -> String:
	if _current_app != null and "APP_ID" in _current_app:
		return _current_app.APP_ID
	return "no_app_id"

## Start the loading sound of the Teleradio.[br]
## This can be used by Applications that have a custom loading bar implemented.
func load_sound_start() -> void:
	if not _current_os_app and _current_app and "cartridge_content" in _current_app:
		cartridge_load_started.emit()
	load_sound_started.emit()

## Stop the loading sound of the Teleradio.
func load_sound_stop() -> void:
	cartridge_load_stopped.emit()
	load_sound_stopped.emit()

## Request ejection of the cartridge from the cartridge drive.
func eject_casette() -> void:
	request_cartridge_eject.emit()

## Block the Cartridge Drive.[br]
## [color=yellow]Important:[/color] This should only be used by OS applications e.g. briefing and debriefing.
func block_cartridge_drive(block:bool):
	cartridge_drive_block.emit(block)
