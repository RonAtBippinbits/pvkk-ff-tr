extends Button

signal hit
signal release

var is_button_pressed := false

var block_input = false: 
	set(v):
		block_input = v
		disabled = v

func _ready():
	as_connected(false)
	connect("button_down", _on_button_down)
	connect("button_up", _on_button_up)

func _on_button_down(play_button_sounds:bool=true):
	if is_button_pressed:
		return
	is_button_pressed = true
	self_modulate = Color.WEB_GRAY
	if play_button_sounds:
		$ButtonPressSound.play()
	hit.emit()

func _on_button_up(play_button_sounds:bool=true):
	self_modulate = Color.WHITE
	if play_button_sounds:
		$ButtonReleaseSound.play()
	release.emit()
	is_button_pressed = false

func as_connected(v:bool):
	modulate = Color.WHITE if v else Color.DIM_GRAY
