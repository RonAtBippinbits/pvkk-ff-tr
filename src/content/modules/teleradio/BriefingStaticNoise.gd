extends AudioStreamPlayer3D

@onready var briefing_static_noise = $BriefingStaticNoise

func _ready():
	finished.connect(onFinished)


func play_line(file_path:String):
	stream = load(file_path)
	play()
	briefing_static_noise.play()

func onFinished():
	briefing_static_noise.stop()

func stop_all():
	stop()
	briefing_static_noise.stop()
