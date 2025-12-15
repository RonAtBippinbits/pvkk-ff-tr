extends TeleradioContent
## This example shows how to use Teleradio OS error messages, TeleradioButtonLabels and the Teleradio Filesystem.

const APP_ID := "example_counter" # This is neccessary to use the Teleradio Filesystem.

var counter := 0
var tween : Tween
var lucky_tween : Tween

func _ready() -> void:
	os.input.connect_button1(on_pressed_button1)
	os.input.connect_button3(show_warning)
	os.input.connect_button4(os.quit_app)
	# APP_ID needs to be defined to use the filesystem and save files in the correct place.
	if os.filesystem.file_exists("save_file"):
		var save_data:String = os.filesystem.load_file("save_file")
		var save_dictionary:Dictionary = JSON.parse_string(save_data)
		counter = save_dictionary.counter
		%CounterLabel.text = str(counter)


func show_warning():
	os.show_error_message("This is an example error message!")


func on_pressed_button1():
	increase_counter(1)


func increase_counter(increase:int):
	counter += increase
	%CounterLabel.text = str(counter)
	$Sfx.play()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel().tween_property(%CounterLabel, "scale", Vector2.ONE, 0.4).from(Vector2(1.4, 1.4)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(%CounterLabel, "rotation", 0.0, 0.4).from(randfn(0.0, 0.15)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	save_counter()
	update_lucky_chance()


func update_lucky_chance():
	if randf() > 0.8:
		if lucky_tween:
			lucky_tween.kill()
		lucky_tween = create_tween()
		lucky_tween.tween_method(lucky_button_active, 1.0, 0.0, 1.0)
		lucky_tween.tween_callback(missed_lucky_chance)
		%ButtonLabels.label_2_visible = true
		os.input.connect_button2(lucky_hit)


func lucky_button_active(v:float):
	%ButtonLabels.label_2 = "Lucky! %.1f" % v


func lucky_hit():
	if lucky_tween:
		lucky_tween.kill()
	os.input.disconnect_from(os.input.just_pressed_b2, lucky_hit)
	%ButtonLabels.label_2_visible = false
	increase_counter(10)


func missed_lucky_chance():
	%ButtonLabels.label_2_visible = false
	os.input.disconnect_from(os.input.just_pressed_b2, lucky_hit)


func save_counter():
	var save_data := {"counter" : counter}
	os.filesystem.save_file("save_file", JSON.stringify(save_data))
