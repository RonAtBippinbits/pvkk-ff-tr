extends Resource
class_name TeleradioBriefingSpeaker

@export_group("Video Files")
@export var talk_streams : Array[VideoStreamTheora]
@export var idle_default_streams : Array[VideoStreamTheora]
@export var idle_harold_streams : Array[VideoStreamTheora]
@export var tea_streams : Array[VideoStreamTheora]

@export_group("Text to Speech Settings")
@export var tts_voice := "ZIRA"
@export var tts_pitch := 0.2
@export var tts_rate := 1.15
