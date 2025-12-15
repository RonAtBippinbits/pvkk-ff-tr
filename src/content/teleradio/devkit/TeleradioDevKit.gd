extends PanelContainer

func _enter_tree():
	GameWorld.initialize_teleradio_content()
	GameWorld.add_teleradio_content("Debug", "Input Debugger", TeleradioEntry.new(
		preload("res://content/teleradio/software/os/apps/inputdebugger/InputDebugger.tscn"),
		{}, false))

func _ready():
	var config : TdkToolsSettings
	if ResourceLoader.exists(TdkConst.TDK_TOOLS_CONFIG_PATH):
		config = load(TdkConst.TDK_TOOLS_CONFIG_PATH)
		if config and config.custom_play_pressed:
			var selected_scene_path := config.content_selected
			if ResourceLoader.exists(selected_scene_path):
				$TeleradioLogic.tos.start_app(load(selected_scene_path))
	if get_tree().has_meta("tdk_start_scene_direct"):
		$TeleradioLogic.tos.start_app(load(get_tree().get_meta("tdk_start_scene_direct")))
		get_tree().remove_meta("tdk_start_scene_direct")
	$TeleradioHardware.set_tv_texture($TeleradioLogic.get_texture())
	$TeleradioLogic.start_forward_input("res://content/teleradio/TeleradioSeatInputProcessor2D.gd")

func show_briefing(mission_id):
	$TeleradioLogic.content.show_mission(mission_id)


func show_content_by_path(content_path:String):
	$TeleradioLogic.show_content(load(content_path))


func _on_volume_slider_value_changed(value):
	%VolumeLabel.text = "Audio: Volume - %s%%" % int(value*100.0)


func _on_bitcrush_slider_value_changed(value):
	%BitcrushLabel.text = "Audio: Bitcrush - %s%%" % int(remap(value, 1.0, 32.0, 0.0, 100.0))


func _on_interrupt_app_check_button_pressed() -> void:
	%TeleradioOS.interrupt_app(%InterruptAppCheckButton.button_pressed)
