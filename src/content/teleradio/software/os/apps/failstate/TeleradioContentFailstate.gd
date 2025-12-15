extends TeleradioContent

var countdown := 30.0

var noise := FastNoiseLite.new()
var loading_progress := 0.0
var loading_speed := 20.0
var countdown_speed := 1.0
var is_loading := true

var self_destruction_started := false
var objection_processing := false


func _ready():
	os.input.disconnect_all_buttons()
	os.input.connect_to(os.input.just_pressed_b1, objection)
	os.input.connect_to(os.input.just_pressed_b2, mute)
	os.input.connect_to(os.input.just_pressed_b3, emergency)
	$SelfdestructAlarm.play()
	Data.listen(self, "event.trailer.stop_self_destruction")

func gameDataChanged(property:String, old_value, new_value):
	match property:
		"event.trailer.stop_self_destruction":
			countdown_speed = 0.0

func objection():
	objection_processing = true
	os.start_load_sound()
	$Option1Text.hide()
	os.input.disconnect_from(os.input.just_pressed_b1, objection)
	$ObjectionOverlay.show()

func mute():
	os.input.disconnect_from(os.input.just_pressed_b2, mute)
	$Option2Text.hide()
	os.stop_load_sound()

func _process(delta):
	if GameWorld.paused:
		return
	countdown -= delta*countdown_speed
	if countdown <= 0.0 and not self_destruction_started:
		countdown = 0.0
		self_destruct()
	$IncomingCall/OptionsPanel3/CountdownLabel.text = "%s:%s" % [str(round(countdown)).pad_zeros(2), str(countdown).pad_decimals(2).split(".")[1]]
	
	if not objection_processing:
		return
	if loading_progress < 110.0:
		loading(delta)
	if loading_progress >= 100.0:
		if is_loading:
			is_loading = false
			os.stop_load_sound()
			%ObjectionResult.show()


func loading(delta):
	var new_progress = delta*loading_speed
	if loading_progress <= 110.0:
		new_progress = delta*max(0.0, noise.get_noise_1d(float(Time.get_ticks_msec())/100.0)+0.5)*loading_speed
		if loading_progress > 85.0:
			var slowdown = clamp(abs(15.0-(loading_progress-85.0))*0.05, 0.02, 1.0)
			new_progress *= slowdown
	loading_progress += new_progress
	%LoadingBar.value = loading_progress


func emergency():
	%Option3Text.hide()
	os.input.disconnect_from(os.input.just_pressed_b3, emergency)
	os.stop_load_sound()
	countdown_speed = 15.0


func self_destruct():
	mute()
	os.stop_load_sound()
	os.input.disconnect_from(os.input.just_pressed_b1, objection)
	os.input.disconnect_from(os.input.just_pressed_b3, emergency)
	set_process(false)
	self_destruction_started = true
	Fade.fade_out(0.05)
	await create_tween().tween_interval(1.0).finished
	get_tree().get_first_node_in_group("game-over").show()
