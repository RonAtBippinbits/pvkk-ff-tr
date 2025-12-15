extends Sprite2D

@onready var focus = $Focus
@onready var progress_bar = $ProgressBar
#@onready var animation_player = $AnimationPlayer

@export var MAX_HEALTH :float = 10

var health: float = 10:
	set(value):
		health = value
		update_progress_bar()
		play_animation()

func update_progress_bar():
	progress_bar.value = (health/MAX_HEALTH) * 100

func take_damage(value):
	health -= value

func show_focus():
	focus.show()

func hide_focus():
	focus.hide()

func play_animation():
	print("hurt_anim")
	#animation_player.play("hurt")
	#implement hurt animation here
