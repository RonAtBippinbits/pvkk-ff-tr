extends TeleradioContent

const APP_ID := "sektorheld2"

enum STATES {MENU, WAVE_START, PLAYING, ZOOMING_IN, ZOOMING_OUT, FIRING_FINISH, SHOOTING}

var state:STATES = STATES.MENU

var current_selection := &"none"
var current_selection_id := -1

var max_aim_time := 2.0
var aim_time := 0.0
var max_radar_time := 5.0
var radar_time := 99.0
var cannon_rotation_time := 0.0
var cannon_angle_target := 0.0
var current_zoom_level := 0
var cannon_turning_speed := 0.25
var next_radar_hit_sound_id := 0
var next_spawn_angle := 0.0
var enemies_killed := 0
var enemies_total := 4
var enemies_spawned := 0
var projectile_trails := {}
var time := 0.0
var score := 0
var wave := 1
var next_spawn_countdown := 0.0
var stage_spawn_time := 15.0

@onready var sectors := [
	%SectorNodeU,
	%SectorNodeD,
	%SectorNodeR,
	%SectorNodeL,
	]
@onready var radar_hit_sounds := [
	$Sounds/RadarHit1,
	$Sounds/RadarHit2,
	$Sounds/RadarHit3,
	$Sounds/RadarHit4, ]
@onready var play_area = %PlayArea
@onready var cannon = %Cannon
@onready var aim_line = %AimLine
@onready var muzzleflash = %Muzzleflash
@onready var radar_pings = %RadarPings
@onready var enemies = %Enemies
@onready var enemy_goal = %EnemyGoal
@onready var spawn_path_outer = %SpawnPathOuter
@onready var spawn_path_inner = %SpawnPathInner


func _ready():
	show_menu_and_reset()


func exit_game():
	os.quit_app()


func show_menu_and_reset():
	clear_old_wave()
	state = STATES.MENU
	os.input.disconnect_all_buttons()
	$Sounds/Music.stop()
	$MainMenu/MenuLabel.hide()
	$MainMenu.show()
	$MainMenu/TitleLabel.modulate.a = 0.0
	$MainMenu/TitleLabel.scale = Vector2.ONE*3.0
	var t := create_tween()
	t.set_parallel().tween_callback($Sounds/Title.play).set_delay(2.5)
	t.tween_callback($Sounds/Explode.play).set_delay(1.5)
	t.tween_property($MainMenu/TitleLabel, "modulate:a", 1.0, 0.8).set_delay(1.5)
	t.tween_property($MainMenu/TitleLabel, "scale", Vector2.ONE, 0.8).set_delay(1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	t.tween_property($MainMenu/Background/Flash, "modulate:a", 0.5, 0.1).set_delay(1.2)
	t.tween_property($MainMenu/Background/Flash, "modulate:a", 0.0, 0.8).set_delay(1.5)
	t.tween_callback(show_title_stage).set_delay(5.0)


func show_title_stage():
	$Sounds/Music.play()
	$MainMenu/MenuLabel.show()
	os.input.connect_to(os.input.just_pressed_b1, start_new_game)
	os.input.connect_to(os.input.just_pressed_b4, exit_game)


func start_new_game():
	clear_old_wave()
	%LoseScreen.hide()
	%SuccessScreen.hide()
	%"2".hide()
	$MainMenu.hide()
	os.input.disconnect_all_buttons()
	os.input.connect_to(os.input.just_pressed_b1, show_menu_and_reset)
	os.input.connect_to(os.input.just_pressed_joyA, on_just_pressed_joy_a)
	os.input.connect_to(os.input.just_pressed_joyB, on_just_pressed_joy_b)
	wave = 0
	prepare_next_wave()


func clear_old_wave():
	for p in projectile_trails.keys():
		p.queue_free()
	get_tree().call_group("tdk-sectorsearch-enemy", "queue_free")
	for c in radar_pings.get_children():
		c.queue_free()


func wave_won():
	reset_zoom(false)
	clear_old_wave()
	state = STATES.WAVE_START
	var t := create_tween()
	await t.tween_interval(2.0).finished
	%SuccessScreen.show()
	$Sounds/WaveWon.play()
	%WaveOverLabel.text = "WAVE %s OVER" % wave
	var t2 := create_tween()
	t2.tween_callback(%SuccessScreen.hide).set_delay(2.0)
	t2.tween_callback(prepare_next_wave).set_delay(1.0)


func prepare_next_wave():
	state = STATES.WAVE_START
	wave += 1
	enemies_killed = 0
	enemies_spawned = 0
	enemies_total = wave+wave
	$Sounds/WaveAlert.play()
	%NextStageScreen.show()
	%WaveLabel.text = "WAVE %s" % wave
	var t := create_tween()
	t.tween_method(wave_countdown, 2.0, 0.0, 2.0)
	t.tween_callback(start_next_wave)


func wave_countdown(t:float):
	%WaveStartLabel.text = "ENEMIES ICOMING IN %.1f" % t
	%WaveFlashLabel.visible = int(t*5.0)%2 == 0


func start_next_wave():
	if state != STATES.WAVE_START:
		return
	state = STATES.PLAYING
	%NextStageScreen.hide()
	start_stage()


func start_stage():
	stage_spawn_time = clamp(30.0-float(wave*2.0), 5.0, 30.0)
	for i in wave+1:
		spawn_enemy()


func _physics_process(delta):
	if state in [STATES.MENU, STATES.WAVE_START]:
		return
	time += delta
	update_stage_content_label()
	spawn_more_enemies(delta)
	check_stage_win_condition()
	update_shooting_aim(delta)
	update_aim_time()
	
	if radar_time > max_radar_time:
		send_radar()
	else:
		radar_time += delta
	
	if state == STATES.SHOOTING:
		cannon.rotation = rotate_toward(cannon.rotation, cannon_angle_target, delta*cannon_turning_speed)
		if abs(angle_difference(cannon.rotation, cannon_angle_target)) <= 0.001:
			shoot()


func _process(_delta):
	%ControlHints.visible = state == STATES.PLAYING
	
	
func update_aim_time():
	if not state == STATES.PLAYING or os.input.joy_axis.length() < 0.4:
		aim_time = 0.0
		return
	var y_dot = os.input.joy_axis.dot(Vector2.UP)
	var x_dot = os.input.joy_axis.dot(Vector2.RIGHT)
	if abs(y_dot) > abs(x_dot):
		if y_dot > 0:
			set_selection(&"up")
		else:
			set_selection(&"down")
	else:
		if x_dot > 0:
			set_selection(&"right")
		else:
			set_selection(&"left")


func spawn_more_enemies(delta):
	if enemies_spawned >= enemies_total:
		return
	next_spawn_countdown += delta
	if next_spawn_countdown >= stage_spawn_time:
		next_spawn_countdown = 0.0
		spawn_enemy()


func check_stage_win_condition():
	if enemies_killed == enemies_total:
		wave_won()


func update_stage_content_label():
	%TimeLabel.text = format_time(time)
	%WaveCountLabel.text = str(wave)
	%ScoreLabel.text = str(score)


func on_just_pressed_joy_b():
	if not state == STATES.PLAYING or current_zoom_level == 0:
		return
	reset_zoom()


func on_just_pressed_joy_a():
	if not state == STATES.PLAYING or current_selection_id == -1:
		return
	state = STATES.ZOOMING_IN
	for i in sectors.size():
		if i == current_selection_id:
			var sector_copy = sectors[i].duplicate()
			add_child(sector_copy)
			sector_copy.zoom(sectors[i].global_position, %Center.global_position)
			$Anchor.global_position = sectors[i].global_position
			play_area.reparent($Anchor, true)
			zoom_in(sectors[i].global_position, %Center.global_position, $Anchor.scale)
			sector_copy.resetted.connect(go_to_next_zoom, CONNECT_ONE_SHOT)
		sectors[i].modulate.a = 0.0
		sectors[i].deselect()
		var t := create_tween()
		t.tween_property(sectors[i], "modulate:a", 1.0, 0.2).set_delay(0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func zoom_in(from:Vector2, to:Vector2, old_zoom:Vector2):
	var t := create_tween()
	t.set_parallel().tween_property($Anchor, "global_position", to, 0.3).from(from).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property($Anchor, "scale", old_zoom*2.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.set_parallel(false).tween_callback(func(): play_area.reparent(self, true))


func go_to_next_zoom():
	current_zoom_level += 1
	state = STATES.PLAYING
	current_selection = &"none"
	current_selection_id = -1
	for s in sectors:
		s.show()


func reset_zoom(with_state_change:=true):
	$Sounds/ZoomOut.play()
	current_zoom_level = 0
	current_selection = &"none"
	current_selection_id = -1
	for s in sectors:
		s.deselect()
	$Anchor.position = Vector2.ZERO
	$Anchor.scale = Vector2.ONE
	var t := create_tween()
	t.set_parallel().tween_property(play_area, "position", Vector2.ZERO, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(play_area, "scale", Vector2.ONE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	if with_state_change:
		state = STATES.ZOOMING_OUT
		t.set_parallel(false).tween_callback(func(): state = STATES.PLAYING)


func set_selection(dir:StringName):
	if current_selection == dir:
		return
	aim_time = 0.0
	$Sounds/SelectSector.play()
	current_selection = dir
	var id := -1
	match dir:
		&"up":
			id = 0
		&"down":
			id = 1
		&"right":
			id = 2
		&"left":
			id = 3
	current_selection_id = id
	for i in sectors.size():
		if i == id:
			sectors[i].select()
		else:
			sectors[i].deselect()


func update_shooting_aim(delta):
	aim_time += delta
	for i in sectors.size():
		if i == current_selection_id:
			sectors[i].aim(aim_time, max_aim_time)
		else:
			sectors[i].aim(0.0, max_aim_time)
	if aim_time >= max_aim_time:
		arm()


func arm():
	aim_time = 0.0
	for i in sectors.size():
		if i == current_selection_id:
			cannon_angle_target = cannon.position.direction_to(play_area.to_local(sectors[i].global_position)).angle()
		sectors[i].reset()
	aim_line.show()
	cannon_rotation_time = angle_difference(cannon.rotation, cannon_angle_target)
	reset_zoom(false)
	state = STATES.SHOOTING
	$Sounds/Turn.play()


func shoot():
	$Sounds/Turn.stop()
	$Sounds/Arm.play()
	aim_line.hide()
	muzzleflash.scale = Vector2.ZERO
	var t := create_tween()
	t.set_parallel().tween_callback($Sounds/Shoot.play).set_delay(1.2)
	t.tween_callback(muzzleflash.show).set_delay(1.2)
	t.tween_callback(release_projectile).set_delay(1.2)
	t.tween_property(muzzleflash, "scale", Vector2.ONE*2.0, 0.2).set_delay(1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	t.tween_callback(muzzleflash.hide).set_delay(1.4)
	state = STATES.FIRING_FINISH
	t.tween_callback(func(): state = STATES.PLAYING).set_delay(1.6)


func release_projectile():
	var new_projectile = load("res://content/teleradioapps/sectorsearch/SectorSearchProjectile.tscn").instantiate()
	new_projectile.dir = Vector2.RIGHT.rotated(cannon_angle_target)
	new_projectile.position = cannon.position + new_projectile.dir*7.0
	new_projectile.start_position = new_projectile.position
	enemies.add_child(new_projectile)
	new_projectile.impact.connect(projectile_hit)
	var new_projectile_trail = load("res://content/teleradioapps/sectorsearch/SectorSearchProjectileTrail.tscn").instantiate()
	new_projectile_trail.following_projectile = new_projectile
	enemies.add_child(new_projectile_trail)
	new_projectile.remove_projectile.connect(projectile_remove.bind(new_projectile_trail))


func projectile_hit(pos:Vector2):
	enemies_killed += 1
	$Sounds/Explode.play()
	var new_explosion = load("res://content/teleradioapps/sectorsearch/SectorSearchExplosion.tscn").instantiate()
	new_explosion.position = pos
	enemies.add_child(new_explosion)
	score += 1 * wave
	var t := create_tween()
	t.tween_property(%ScoreLabel, "modulate", Color(3,3,3,1), 0.1)
	t.tween_property(%ScoreLabel, "modulate", Color("#67B6BD"), 4.0)


func projectile_remove(p:Node2D, trail:Node2D):
	trail.decay()
	p.queue_free()


func send_radar():
	$Sounds/RadarWave.play()
	radar_time = 0.0
	var new_radar_wave = load("res://content/teleradioapps/sectorsearch/SectorSearchRadarPing.tscn").instantiate()
	radar_pings.add_child(new_radar_wave)
	new_radar_wave.position = Vector2.ZERO
	new_radar_wave.found_enemy.connect(on_found_enemy)


func on_found_enemy(enemy_position:Vector2):
	var dist_mod = clamp(enemy_position.distance_to(enemy_goal.position), 20.0, 150.0)
	next_radar_hit_sound_id = wrapi(next_radar_hit_sound_id+1, 0, 4)
	radar_hit_sounds[next_radar_hit_sound_id].pitch_scale = remap(dist_mod, 20.0, 150.0, 1.5, 0.5)
	radar_hit_sounds[next_radar_hit_sound_id].volume_db = linear_to_db(remap(dist_mod, 20.0, 150.0, 0.7, 0.3))
	radar_hit_sounds[next_radar_hit_sound_id].play()
	var new_enemy_signal = load("res://content/teleradioapps/sectorsearch/SectorSearchEnemySignal.tscn").instantiate()
	new_enemy_signal.position = enemy_position
	enemies.add_child(new_enemy_signal)


func spawn_enemy():
	$Sounds/NewSignal.play()
	enemies_spawned += 1
	next_spawn_angle = wrapf(next_spawn_angle+randf_range(0.3, 0.7), 0.0, 1.0)
	var optimized = snap_to_corners(next_spawn_angle)
	var pos_i:Vector2 = spawn_path_inner.curve.sample_baked(optimized*spawn_path_inner.curve.get_baked_length())
	var pos_o:Vector2 = spawn_path_outer.curve.sample_baked(optimized*spawn_path_outer.curve.get_baked_length())
	var new_enemy = load("res://content/teleradioapps/sectorsearch/SectorSearchEnemyShip.tscn").instantiate()
	new_enemy.position = lerp(pos_i, pos_o, randf())
	new_enemy.goal = enemy_goal.position
	new_enemy.reached_goal.connect(lose_game, CONNECT_ONE_SHOT)
	enemies.add_child(new_enemy)


func snap_to_corners(value: float) -> float:
	var focus_points = [0.0, 0.25, 0.5, 0.75, 1.0]
	var closest_focus = focus_points[0]
	var min_distance = abs(value - closest_focus)
	for focus_point in focus_points:
		var distance = abs(value - focus_point)
		if distance < min_distance:
			closest_focus = focus_point
			min_distance = distance
	return lerp(value, closest_focus, 0.1)


func format_time(seconds: float) -> String:
	var minutes = int(seconds / 60.0)
	var remaining_seconds = int(seconds) % 60
	var tenths = int((seconds - int(seconds)) * 10)
	return str(minutes) + ":" + str(remaining_seconds).pad_zeros(2) + "." + str(tenths)


func lose_game():
	if %LoseScreen.visible:
		return
	$LoseScreen/Panel/LoseLabel.text = "YOU DEFEATED %s WAVES!" % int(wave-1)
	$LoseScreen/Panel/LoseLabel3.text = "YOUR SCORE: %s" % int(score)
	reset_zoom(false)
	$Sounds/WaveAlert.play()
	$Sounds/Explode.play()
	state = STATES.WAVE_START
	%LoseScreen.show()
	%"2".show()
	os.input.connect_to(os.input.just_pressed_b2, start_new_game)
