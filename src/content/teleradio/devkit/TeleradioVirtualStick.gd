extends Control

signal value_changed

var value := Vector2.ZERO
var is_dragging := false
var stop_drag := false

@onready var button_stick = $ButtonStick


func init():
	pass

func get_percentage() -> float:
	return 0.0

func set_absolute_value(v):
	if is_dragging:
		return
	value = v
	value_changed.emit(value)

func get_absolute_value():
	return value


func _physics_process(delta):
	if is_dragging:
		value = get_local_mouse_position().limit_length(30)/30.0
		value_changed.emit(value)
	if stop_drag:
		stop_drag = false
		value = Vector2.ZERO
		is_dragging = false
		value_changed.emit(value)
	button_stick.position = lerp(button_stick.position, Vector2(-32, -32) + value*30.0, delta*40.0)


func _on_button_stick_button_down():
	is_dragging = true


func _on_button_stick_button_up():
	stop_drag = true
