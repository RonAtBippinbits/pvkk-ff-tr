extends Node2D

const CHAR_OFF := "-"
const CHAR_ON := "▌"

func _ready():
	hide()

func set_volume(v):
	show()
	if v <= 0.0:
		$VolumeLabel.text = "MUTED"
	else:
		var string := ""
		var on_chars:int =  int(round(v*10.0))
		var off_chars:int = 10-on_chars
		for i in on_chars:
			string += CHAR_ON
		for i in off_chars:
			string += CHAR_OFF
		$VolumeLabel.text = string
	$Timer.start()

func _on_timer_timeout():
	hide()
