extends AnimatedSprite2D


@onready var focus = $Focus
@onready var progress_bar = $ProgressBar
@onready var animation_player = $AnimationPlayer

#@export var visual : Texture2D
@export var MAX_HEALTH :float = 1
@export var attack : int = 1
@export var entity_type : String

signal died(entity)

var health: float = 10:
	set(value):
		health = value
		update_progress_bar()
		play_animation()
		if health <= 0:
			queue_free()
			emit_signal("died", self)

func _ready():
	load_enemy_data(entity_type)
	update_progress_bar()

func load_enemy_data(entity_type: String):
	if entity_data.has(entity_type):
		var data = entity_data[entity_type]
		play(data.visual)
		MAX_HEALTH = data.health
		health = data.health
		attack = data.attack
		print("a: ", attack, "h: ", health)
	else:
		queue_free()
		emit_signal("died", self)

func update_progress_bar():
	progress_bar.value = (health/MAX_HEALTH) * 100

func take_damage(value):
	health -= value

func show_focus():
	focus.show()

func hide_focus():
	focus.hide()

func play_animation():
	animation_player.play("take_dmg")
# -------------------------------------------------------
var entity_data = {
	#character data
	"warrior": {
		"visual": "battler_1",
		"health": 18,
		"attack": 3
	},
	"b_mage": {
		"visual": "battler_2",
		"health": 12,
		"attack": 1
	},
	"w_mage": {
		"visual": "battler_3",
		"health": 12,
		"attack": 1
	},
	#enemy data
	"goblin_1": {
		"visual": "e_goblin_1",
		"health": 3,
		"attack": 1
	},
	"goblin_2": {
		"visual": "e_goblin_2",
		"health": 12,
		"attack": 3,
	},
	#boss data
}
