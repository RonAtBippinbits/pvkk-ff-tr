extends VBoxContainer

@export var teleradio : TeleradioLogic

var current : Node = null
var noise := FastNoiseLite.new()
var noise_time := randf()
var loading := false
var block_busy_led := false

func _ready() -> void:
	noise.fractal_octaves = 1
	teleradio.tos.cartridge_load_started.connect(set_loading.bind(true))
	teleradio.tos.cartridge_load_stopped.connect(set_loading.bind(false))
	teleradio.tos.cartridge_busy_led_blocked.connect(func(v:bool): block_busy_led = v)

func _process(delta) -> void:
	if GameWorld.paused:
		return
	if loading and not block_busy_led:
		noise_time += delta*600.0
		%LedBusy.powered(noise.get_noise_1d(noise_time) > 0.0)
	if block_busy_led:
		%LedBusy.powered(false)

func set_loading(loading:bool) -> void:
	self.loading = loading
	if not loading:
		%LedBusy.powered(false)
