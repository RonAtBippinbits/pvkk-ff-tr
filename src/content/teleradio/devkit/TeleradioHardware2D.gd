extends TeleradioHardware
class_name TeleradioHardware2D

@export var buttons:Array[Node]= []


func _ready() -> void:
	super._ready()
	for button in buttons:
		button.modulate = Color.WEB_GRAY
		button.set_meta("active", false)


func _process(_delta):
	var connected_hardware := input.get_buttons_connected_dict()
	for button in buttons:
		if connected_hardware[button] and not button.get_meta("active"):
			if play_button_connect_sounds:
				%TurnOnSound.play()
			button.modulate = Color(2, 1.412, 0.0, 1.0)
			button.set_meta("active", true)
		elif not connected_hardware[button] and button.get_meta("active"):
			if play_button_connect_sounds:
				%TurnOffSound.play()
			button.modulate = Color.WEB_GRAY
			button.set_meta("active", false)


func set_tv_texture(texture:ViewportTexture):
	$Outputs/MarginContainer/SubViewportContainer/SubViewport/Node3D/room_teleradio_mesh_new/SM_Teleradio_Screen.material_override.set_shader_parameter("tv_image", texture)
