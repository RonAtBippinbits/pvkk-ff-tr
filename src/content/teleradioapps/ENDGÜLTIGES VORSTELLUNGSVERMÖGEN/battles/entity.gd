extends AnimatedSprite2D

@onready var focus = $Focus
@onready var progress_bar = $ProgressBar
@onready var animation_player = $AnimationPlayer

@export var MAX_HEALTH :float = 1
@export var attack : int = 1
@export var entity_type : String
@export var is_character: bool = false
var character_dead: bool = false

var health: float = 10:
	set(value):
		health = value
		update_progress_bar()
		if health != MAX_HEALTH:
			play_animation()
		if health <= 0:
			character_dead = true
			if is_character:
				play(entity_type + "_dead")
			else:
				queue_free()

func _ready():
	load_entity_data(entity_type)
	update_progress_bar()

func load_entity_data(entity_key: String):
	if !focus: focus = $Focus
	if !progress_bar: progress_bar = $ProgressBar
	if !animation_player: animation_player = $AnimationPlayer
	if entity_data.has(entity_key):
		var data = entity_data[entity_key]
		play(data.visual)
		MAX_HEALTH = data.health
		health = data.health
		attack = data.attack
		entity_type = entity_key

func update_progress_bar():
	progress_bar.value = (health/MAX_HEALTH) * 100

func take_damage(value):
	health -= value

func revive(): # to revive characters at the end of a battle
	if character_dead:
		character_dead = false
		play(entity_type)
		health = 1

func recover():
	health = MAX_HEALTH

func show_focus():
	focus.show()

func hide_focus():
	focus.hide()

func play_animation():
	animation_player.play("take_dmg")
# ------------------------------------------------------- #
var entity_data = { # separate this later 
#character data
	"warrior": {
		"visual": "battler_1",
		"health": 19,
		"attack": 3
	},
	"b_mage": {
		"visual": "battler_2",
		"health": 12,
		"attack": 2
	},
	"w_mage": {
		"visual": "battler_3",
		"health": 13,
		"attack": 2
	},
#enemy data
	"goblin_1": {
		"visual": "e_goblin_1",
		"health": 3,
		"attack": 2
	},
	"goblin_2": {
		"visual": "e_goblin_2",
		"health": 1,
		"attack": 1,
	},
	"skeleton_1": {
		"visual": "e_skeleton_1",
		"health": 5,
		"attack": 3,
	},
	"skeleton_2": {
		"visual": "e_skeleton_2",
		"health": 1,
		"attack": 1,
	},
	"spider_1": {
		"visual": "e_spider_1",
		"health": 9,
		"attack": 1,
	},
	"spider_2": {
		"visual": "e_spider_2",
		"health": 1,
		"attack": 1,
	},
#boss data
	"e_boss_1": {
		"visual": "e_boss_1",
		"health": 25,
		"attack": 3,
	},
	"e_boss_2": {
		"visual": "e_boss_2",
		"health": 1,
		"attack": 1,
	}
}
