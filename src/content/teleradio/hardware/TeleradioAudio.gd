extends Node
class_name TeleradioAudio
## Class handling recording of the [code]TeleradioApp[/code] bus and playback on the Teleradio speaker.
## 
## [color=yellow]Important:[/color] As an app developer you do not need to interact with the instance of this class directly.
## To enable playback via the Teleradio speaker you just need to setup your [AudioStreamPlayer] to use the [code]TeleradioApp[/code] bus.[br][br]
## Use the [code]TDK Audio Check[/code] tab at the bottom to see if all the [AudioStreamPlayer] nodes in your scenes are correctly configured.

var _sample_rate := AudioServer.get_mix_rate()
var audio_player_left : Node ## The AudioStreamPlayer which plays the TeleradioApp bus output. Left side (mono output).
var audio_player_right : Node ## The AudioStreamPlayer which plays the TeleradioApp bus output. Right side (mono output).

@export var _volume_display:Node2D
@export_range(1.0, 32.0) var bitcrush_value := 1.0
@export_range(1.0, 32.0) var volume_value := 0.8

var _capture_effect : AudioEffectCapture
var _playback: AudioStreamGeneratorPlayback
var _buffer_length := 0.1


func _ready():
	set_volume(volume_value, false)
	_capture_effect = AudioServer.get_bus_effect(AudioServer.get_bus_index(&"TeleradioApp"), 0)
	if _capture_effect == null:
		push_error("Capture effect not found! Ensure it's added to the bus.")
	_capture_effect.buffer_length = _buffer_length
	var generator:AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = _sample_rate
	generator.buffer_length = _buffer_length
	audio_player_left.stream = generator
	audio_player_left.play(0.0)
	audio_player_right.stream = generator
	audio_player_right.play(0.0)
	_playback = audio_player_left.get_stream_playback()


func set_bitcrush(bitcrush_value:=1.0):
	self.bitcrush_value = clamp(bitcrush_value, 1.0, 32.0)


func set_volume(volume_value:float, show_visual:=true):
	self.volume_value = volume_value
	if volume_value <= 0.0:
		set_process(false)
	else:
		set_process(true)
	if show_visual:
		_volume_display.set_volume(volume_value)
	audio_player_left.volume_db = clamp(linear_to_db(volume_value), -70.0, 0.0)
	audio_player_right.volume_db = clamp(linear_to_db(volume_value), -70.0, 0.0)


func _process(_delta):
	if not _capture_effect or not _playback:
		return
	_play_data(_capture_effect.get_buffer(_capture_effect.get_frames_available()))


func _play_data(data : PackedVector2Array):
	_playback.push_buffer(_apply_bitcrush(data, bitcrush_value))


func _apply_bitcrush(audio_buffer: PackedVector2Array, crush:float) -> PackedVector2Array:
	var bit_rate:int = floor(crush)
	if bit_rate <= 1:
		return audio_buffer
	
	for i in range(0, audio_buffer.size(), bit_rate):
		for j in range(i+1, min(i + bit_rate, audio_buffer.size())):
			audio_buffer[j] = audio_buffer[i]

	return audio_buffer
