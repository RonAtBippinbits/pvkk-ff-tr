extends Node2D

signal loading_finished
signal loading_processing
signal loading_started

var noise:= FastNoiseLite.new()
var loading_progress:= 0.0
var loading_speed := 200.0
var is_loading:= true


func _ready() -> void:
	if not is_loading:
		set_process(false)


func _process(delta: float) -> void:
	if loading_progress < 110.0:
		loading(delta)
	if loading_progress >= 100.0:
		if is_loading:
			is_loading = false
		loading_speed = 700.0
	if loading_progress >= 104.0:
		loading_finished.emit()
		hide()
		set_process(false)


func start_loading(loading_speed_multiplier:=1.0, reset:=false):
	if reset:
		loading_speed = 200.0*loading_speed_multiplier
	set_process(true)
	show()
	%LoadingBar.value = 0.0
	loading_started.emit()
	is_loading = true
	loading_progress = -20.0


func loading(delta):
	loading_processing.emit()
	var new_progress = delta*loading_speed
	if loading_progress <= 110.0:
		new_progress = delta*max(0.0, noise.get_noise_1d(float(Time.get_ticks_msec())/100.0)+0.5)*loading_speed
		if loading_progress > 95.0:
			new_progress *= 0.2
	loading_progress += new_progress
	%LoadingBar.value = loading_progress


func stop_loading():
	hide()
	set_process(false)
	is_loading = false
	loading_finished.emit()
