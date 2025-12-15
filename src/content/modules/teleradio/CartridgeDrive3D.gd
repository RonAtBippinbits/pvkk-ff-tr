extends Useable

const CASSETTE_EMPTY = "empty"
const CASSETTE_OUT = "out"
const CASSETTE_IN = "in"
const CASSETTE_MOVING_TO_IN := "moving"
const CASSETTE_LOCKING := "locking"
const CASSETTE_UNLOCKING := "unlocking"
const CASSETTE_READY := "ready"
const CASSETTE_WAITING := "waiting"

@export var teleradio : TeleradioLogic

var state := CASSETTE_EMPTY
var is_blocked := false
var current : Carryable = null
var move_tween : Tween
var noise := FastNoiseLite.new()
var noise_time := randf()
var loading := false
var block_busy_led := false

@onready var start_position = $StartPosition

func _ready() -> void:
	noise.fractal_octaves = 1
	teleradio.tos.request_cartridge_eject.connect(unlock_cassette)
	teleradio.tos.cartridge_drive_block.connect(block_drive)
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
	if state == CASSETTE_MOVING_TO_IN:
		current.global_position = lerp(current.global_position, start_position.global_position, delta*6.0)
		current.global_rotation.x = lerp_angle(current.global_rotation.x, start_position.global_rotation.x, delta*8.0)
		current.global_rotation.y = lerp_angle(current.global_rotation.y, start_position.global_rotation.y, delta*8.0)
		current.global_rotation.z = lerp_angle(current.global_rotation.z, start_position.global_rotation.z, delta*8.0)
		var dist = current.global_position.distance_to(start_position.global_position)
		if dist <= 0.001:
			current.global_rotation = start_position.global_rotation
			state = CASSETTE_LOCKING
			$CassetteEject.play()
			if move_tween:
				move_tween.kill()
			move_tween = create_tween()
			move_tween.tween_property(current, "global_position", $EndPosition.global_position, 1.68).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			move_tween.tween_callback(locking_cassette).set_delay(0.1)


func set_loading(loading:bool) -> void:
	self.loading = loading
	if not loading:
		%LedBusy.powered(false)


func block_drive(is_blocked:bool) -> void:
	if current or state != CASSETTE_EMPTY:
		self.is_blocked = is_blocked
		return
	if is_blocked:
		self.is_blocked = true
		block_use = true
		if move_tween:
			move_tween.kill()
		move_tween = create_tween()
		move_tween.tween_property(%CartridgeLock, "rotation:z", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		%LedSlot.powered(true)
	else:
		if move_tween:
			move_tween.kill()
		move_tween = create_tween()
		move_tween.tween_property(%CartridgeLock, "rotation:z", PI/2.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		move_tween.tween_callback(func(): 
			%LedSlot.powered(false)
			block_use = false
			self.is_blocked = false
		)

func combine(player, item:Useable) -> void:
	block_use = true
	current = item
	current.block_input = true
	player.remove_carryable(self)
	state = CASSETTE_MOVING_TO_IN


func locking_cassette() -> void:
	if state != CASSETTE_LOCKING:
		return
	state = CASSETTE_IN
	%LedSlot.powered(true)
	if move_tween:
		move_tween.kill()
	move_tween = create_tween()
	move_tween.tween_property(%CartridgeLock, "rotation:z", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	move_tween.tween_callback(play_cassette).set_delay(0.1)


func play_cassette() -> void:
	if state != CASSETTE_IN:
		return
	
	state = CASSETTE_READY
	current.play_cassette(teleradio.tos)

func unlock_cassette() -> bool:
	if not state in [CASSETTE_READY, CASSETTE_IN, CASSETTE_MOVING_TO_IN, CASSETTE_LOCKING]:
		return false
	state = CASSETTE_OUT
	if move_tween:
		move_tween.kill()
	move_tween = create_tween()
	move_tween.tween_property(%CartridgeLock, "rotation:z", PI/2.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	move_tween.tween_callback(eject_cassette).set_delay(0.1)
	return true

func eject_cassette():
	%LedSlot.powered(false)
	$CassetteLoad.play()
	if move_tween:
		move_tween.kill()
	move_tween = create_tween()
	move_tween.tween_property(current, "global_position", $StartPosition.global_position, 1.68).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	move_tween.tween_callback(cassette_to_player)

func cassette_to_player():
	state = CASSETTE_WAITING
	current.picked_up.connect(clear_cassette, CONNECT_ONE_SHOT)
	current.block_input = false

func clear_cassette():
	if not is_blocked:
		block_use = false
	else:
		%LedSlot.powered(true)
		if move_tween:
			move_tween.kill()
		move_tween = create_tween()
		move_tween.tween_property(%CartridgeLock, "rotation:z", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	current = null
	state = CASSETTE_EMPTY
