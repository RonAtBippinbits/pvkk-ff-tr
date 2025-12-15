extends Control

const RESULTBOX = preload("res://content/teleradio/software/os/apps/briefing/TeleradioContentBriefingResultContainer.tscn")

var result_containers := []
var stashed_containers_combat := []
var stashed_containers_general := []
var total_points := 0
var tween : Tween

func update_content():
	for c in result_containers:
		c.queue_free()
	for c in stashed_containers_combat:
		c.queue_free()
	for c in stashed_containers_general:
		c.queue_free()
	result_containers.clear()
	stashed_containers_combat.clear()
	stashed_containers_general.clear()
	
	%Combatbox.hide()
	%Generalbox.hide()
	%TotalBox.hide()
	%PerformanceRatingLabel.modulate.a = 0.0
	
	%MissionTitleResult.text = Data.of("mission.current").title
	
	# Combat Results
	# Ships
	var enemies_destroyed:Dictionary= Data.of("missionstats.enemies_destroyed")
	for c in enemies_destroyed:
		var new_enemy_result = RESULTBOX.instantiate()
		new_enemy_result.description = str(enemies_destroyed[c]) + "x Terminated " + tr(c)
		new_enemy_result.points = enemies_destroyed[c] * 3
		result_containers.append(new_enemy_result)
		stashed_containers_combat.append(new_enemy_result)
	
	# Missed Shots
	var misses = Data.of("missionstats.shots_fired") - Data.of("missionstats.hits")
	if misses > 0:
		var new_missed_result = RESULTBOX.instantiate()
		new_missed_result.description = str(misses)+" Missed Shot"
		new_missed_result.points = -misses
		result_containers.append(new_missed_result)
		stashed_containers_combat.append(new_missed_result)
	
	# Missiles
	var missiles_launched = Data.of("missionstats.missiles_launched")
	if missiles_launched > 0:
		var new_missiles_result = RESULTBOX.instantiate()
		new_missiles_result.description = str(Data.of("missionstats.missiles_launched"))+"x Defense Missile launched"
		new_missiles_result.points = -Data.of("missionstats.missiles_launched")
		result_containers.append(new_missiles_result)
		stashed_containers_combat.append(new_missiles_result)
	
	# General Performance	
	# Shut Down Systems
	if Data.of("cannon.booted"):
		var new_shutdown_penalty = RESULTBOX.instantiate()
		new_shutdown_penalty.description = "Systems not shut down"
		new_shutdown_penalty.points = -1
		result_containers.append(new_shutdown_penalty)
		stashed_containers_general.append(new_shutdown_penalty)
	
	show()
	play_animation()


func play_animation():
	if tween:
		tween.kill()
	tween = create_tween()
	var delay := 0.1
	tween.set_parallel().tween_callback(%Combatbox.show).set_delay(delay)
	for scc in stashed_containers_combat:
		tween.tween_callback(add_combat_container.bind(scc)).set_delay(delay)
		delay += 0.1
	delay += 0.3
	tween.tween_callback(%Generalbox.show).set_delay(delay)
	for scc in stashed_containers_general:
		tween.tween_callback(add_general_container.bind(scc)).set_delay(delay)
		delay += 0.1
	delay += 0.3
	tween.tween_callback(show_total_points).set_delay(delay)
	delay += 0.8
	tween.tween_callback(show_rating).set_delay(delay)


func add_combat_container(c):
	play_sound(c.points)
	%CombatResultContainer.add_child(c)


func add_general_container(c):
	play_sound(c.points)
	%GeneralContainer.add_child(c)


func show_total_points():
	total_points = 0
	for r in result_containers:
		total_points += r.points
	play_sound(total_points)
	%TotalPointsLabel.text = str(total_points) if total_points <= 0 else "+" + str(total_points)
	%TotalBox.show()


func play_sound(_points):
	$MissionResultBlip.play()
	# These would need to be refactored to audio players if we ever use them again
	#if points > 0:
		#owner.teleradio.play_sound_once.emit("res://sounds/SFX/console/display/wav/PVKK_sfx_Display_Radar_Target_Lock.wav")
	#elif points < 0:
		#owner.teleradio.play_sound_once.emit("res://sounds/SFX/console/display/wav/PVKK_sfx_Display_Radar_Target_Unlock.wav")


func show_rating():
	var rating_string = ""
	for rating in CONST.MISSIONSTATS_RATINGS:
		if total_points >= rating:
			rating_string = CONST.MISSIONSTATS_RATINGS[rating]
		if total_points < rating:
			break
	play_sound(total_points)
	%PerformanceRatingLabel.text = "Performance Rating: %s" % rating_string
	%PerformanceRatingLabel.modulate.a = 1.0


func display_time(t:float= 0.0, is_decimal:bool= true) -> String:
	var s_hour = str(int(t / 3600.0)) + ":" if int(t / 3600.0) > 0 else ""
	var s_min = str(int(t / 60.0) % 60).pad_zeros(2 if s_hour != "" else 0) + ":" if int(t / 60.0) % 60 > 0 or s_hour != "" else ""
	var s_sec = str(fmod(t, 60)).pad_zeros(2 if s_min != "" else 0).pad_decimals(1 if is_decimal else 0) + (" sec" if s_min == "" else "")
	
	return s_hour + s_min + s_sec
	
