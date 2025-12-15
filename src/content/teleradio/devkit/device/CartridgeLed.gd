extends ColorRect


func _ready():
	powered(false)


func powered(is_powered:bool):
	if is_powered:
		modulate = Color.WHITE
	else:
		modulate = Color(0.2,0.2,0.2)
