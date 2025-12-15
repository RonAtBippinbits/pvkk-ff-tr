extends TeleradioContent

signal request_quit_screensaver

@export var object_size:Vector2 = Vector2(70, 75)

var screen_size:Vector2 = Vector2(600, 450)

var speed: float = 150.0
var direction: Vector2 = Vector2(1, 1).normalized()

@onready var logo := $Logo

func _ready():
	if Data.ofOr("mission.state", CONST.MISSION_STATE_IDLE) == CONST.MISSION_STATE_FINISHED:
		$GoodNight.show()
		logo = null
		$Logo.queue_free()
	os.input.disconnect_all_buttons()
	if GameWorld.build_type != CONST.BUILD_TYPE.EXHIBITION:
		os.input.connect_to(os.input.just_pressed_b1, func(): request_quit_screensaver.emit())


func _process(delta):
	if not logo:
		return
	# Move the object
	logo.position += direction * speed * delta
	
	# Check for boundary collisions
	if logo.position.x < object_size.x or logo.position.x > screen_size.x - object_size.x:
		#os.audio.play($IconBumpSound)
		$IconBumpSound.play()
		direction.x *= -1
		logo.position.x = clamp(logo.position.x, object_size.x, screen_size.x - object_size.x)
	if logo.position.y < object_size.y or logo.position.y > screen_size.y - object_size.y:
		#os.audio.play($IconBumpSound)
		$IconBumpSound.play()
		direction.y *= -1
		logo.position.y = clamp(logo.position.y, object_size.y, screen_size.y - object_size.y)
