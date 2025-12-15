extends TeleradioContent


func _ready() -> void:
	for s in os.input._connected_hardware.keys():
		os.input.connect_to(s, signal_received.bind(s.get_name()))


func _process(delta):
	var debug_text	:= "Side Buttons\n"
	debug_text		+= " Button 1: %s\n" % os.input.button1_down
	debug_text 		+= " Button 2: %s\n" % os.input.button2_down
	debug_text		+= " Button 3: %s\n" % os.input.button3_down
	debug_text		+= " Button 4: %s\n\n" % os.input.button4_down
	debug_text		+= "Joystick\n"
	debug_text		+= " Joystick Button A: %s\n" % os.input.joy_buttonA_down
	debug_text		+= " Joystick Button B: %s\n" % os.input.joy_buttonB_down
	debug_text		+= " Joystick Axis:\n\n\n\n\n\n\n"
	debug_text		+= "Signals:\n\n  >"
	$Label.text = debug_text
	
	%Joystick.position = os.input.joy_axis*20.0


func signal_received(text:String):
	var new:Label = %EventTemplate.duplicate()
	new.text = text
	new.show()
	add_child(new)
	var t := new.create_tween()
	t.set_parallel().tween_property(new, "position:x", randf_range(190.0, 260.0), 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.set_parallel().tween_property(new, "position:y", 430.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	t.tween_property(new, "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	t.tween_callback(new.queue_free).set_delay(1.0)
	
