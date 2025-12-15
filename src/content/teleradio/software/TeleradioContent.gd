extends Node
class_name TeleradioContent
## The base class for content and applications that run on the [TeleradioOS] - either as a cartridge or installed onto the OS.
##
## Extending this class as a scene roots script enables the scene to be loaded as an app on the Teleradio.[br]
## [color=yellow]💡 Tip: running a scene with this script from the editor via F6 launches it in the TDK.[/color][br][br]
## TO DO: Document how [member cartridge_content] works.

var os : TeleradioOS = null
var cartridge_content : CartridgeContent
var content_parameters : Dictionary


func _enter_tree() -> void:
	if get_tree().current_scene == self:
		get_tree().set_meta("tdk_start_scene_direct", self.scene_file_path)
		get_tree().change_scene_to_file("res://content/teleradio/devkit/TeleradioDevKit.tscn")
		set_script(null)

func init(_os:TeleradioOS):
	os = _os
