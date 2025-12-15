extends TeleradioHardware
class_name TeleradioHardware3D

const BTN_MAT = preload("res://content/materials/mat_paint_white.tres")
const BTN_MAT_ACT = preload("res://content/materials/mat_paint_white_backlit.tres")

@onready var button_inputs := [
	$Buttons/HitButtonKeypad1,
	$Buttons/HitButtonKeypad2,
	$Buttons/HitButtonKeypad3,
	$Buttons/HitButtonKeypad4
	]
@onready var button_meshes := [
	$"Buttons/HitButtonKeypad1/MovingPart/keypad-big-button2",
	$"Buttons/HitButtonKeypad2/MovingPart/keypad-big-button2",
	$"Buttons/HitButtonKeypad3/MovingPart/keypad-big-button2",
	$"Buttons/HitButtonKeypad4/MovingPart/keypad-big-button2" ]


func _ready() -> void:
	super._ready()
	set_tv_texture($TeleradioLogic.get_texture())
	for i in button_inputs.size():
		button_inputs[i].set_meta("active", false)
		button_meshes[i].material_override = BTN_MAT


func update_button_lights() -> void:
	var connected_hardware := input.get_buttons_connected_dict()
	for i in button_inputs.size():
		var button = button_inputs[i]
		if connected_hardware[button] and not button.get_meta("active"):
			if play_button_connect_sounds:
				%TurnOnSound.play()
			button_meshes[i].material_override = BTN_MAT_ACT
			button.set_meta("active", true)
		elif not connected_hardware[button] and button.get_meta("active"):
			if play_button_connect_sounds:
				%TurnOffSound.play()
			button_meshes[i].material_override = BTN_MAT
			button.set_meta("active", false)

func set_tv_texture(texture:ViewportTexture):
	$TeleradioMesh.setScreenTexture(texture)
