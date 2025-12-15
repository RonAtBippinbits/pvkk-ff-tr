extends Node
class_name TeleradioHardware

var is_ringing := false
var input : TeleradioInput
var ring_timer := Timer.new()
var play_button_connect_sounds := false

@onready var teleradio_logic:TeleradioLogic = %TeleradioLogic


func _enter_tree():
	add_child(ring_timer)
	ring_timer.wait_time = 3.0
	ring_timer.one_shot = true
	ring_timer.timeout.connect(_on_ring_timer_timeout)
	add_to_group("teleradio")


func _ready():
	Data.listen(self, "mission.state")
	var t := create_tween()
	t.tween_callback(func(): play_button_connect_sounds = true).set_delay(0.5)
	teleradio_logic.ring_start.connect(_on_teleradio_logic_ring_start)
	teleradio_logic.ring_stop.connect(_on_teleradio_logic_ring_stop)
	teleradio_logic.load_sound_start.connect(_on_teleradio_logic_load_start)
	teleradio_logic.load_sound_stop.connect(_on_teleradio_logic_load_stop)


func _process(_delta):
	update_button_lights()


func gameDataChanged(property:String, _old_value, new_value):
	if property == "mission.state":
		if new_value == CONST.MISSION_STATE_DEBRIEFING:
			start_debriefing_call()
		if new_value == CONST.MISSION_STATE_FAILED:
			start_fail_call()


func update_button_lights():
	pass


func pause_changed(is_paused:bool):
	var pause_volume:float= -80.0 if is_paused else -3.0
	%RingSound.volume_db = pause_volume
	%LoadingSound.volume_db = pause_volume


func start_briefing_call(mission_id:String):
	%TeleradioLogic.tos._start_briefing(mission_id)


func start_debriefing_call():
	%TeleradioLogic.tos._start_debriefing()


func start_fail_call():
	$FailstateTeleradioLamp.show()
	%TeleradioLogic.tos._start_fail_call()


func _on_teleradio_logic_ring_start():
	is_ringing = true
	%RingSound.play()
	


func _on_teleradio_logic_ring_stop():
	is_ringing = false
	%RingSound.stop()


func stop_call():
	%RingSound.stop()


func _on_teleradio_logic_load_start():
	%LoadingSound.play(randf()*0.7)


func _on_teleradio_logic_load_stop():
	%LoadingSound.stop()


func _on_ring_timer_timeout():
	if is_ringing and not %RingSound.playing:
		%RingSound.play()


func _on_ring_sound_finished():
	if is_ringing:
		ring_timer.start()
