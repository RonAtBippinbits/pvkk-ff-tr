extends TeleradioContent

signal content_finished

const SPEAKER_PATH := "res://content/teleradio/software/os/apps/briefing/characters/speaker_%s.tres"
const BRIEFING_VIDEO_FLUFF := "%s\nA. 19-299-2-PVKK"

var current_step:int

enum CALL_STAGE {OFF, INCOMING, BRIEFING, DEBRIEFING, DEBRIEF_UPGRADES, DEBRIEF_TEA}
var current_stage:CALL_STAGE = CALL_STAGE.OFF
var current_sentence_id := 0
var current_teleradio_state:TeleradioState
var block_continue := 0.0
var clear_subtitle_tween:Tween
var tea_time := false
var char_is_talking := false
var briefing_mission_id := ""
var current_speaker_id := ""
var speakers := {}

@onready var MainText = %MainText
@onready var CharacterName = %CharacterName


func _enter_tree():
	%MissionSummary.hide()
	%MissionResult.hide()
	$IncomingCall.show()
	%UpgradeSelection.os = os


func _ready():
	os.block_cartridge_drive(true)
	os.input.disconnect_all_buttons()
	Data.listen(self, "mission.state", true)
	Data.listen(self, "event.drank_tea")
	CharacterName.text = ""
	MainText.text = ""
	
	$ButtonLabels.hide_all()
	if briefing_mission_id != "":
		await create_tween().tween_interval(0.2).finished
		show_mission(briefing_mission_id)


func _exit_tree():
	os.block_cartridge_drive(false)


func pause_changed(is_paused:bool):
	if is_paused:
		%IcomingCallAnimation.pause()
		if char_is_talking:
			DisplayServer.tts_pause()
	else:
		%IcomingCallAnimation.play("call")
		if char_is_talking:
			DisplayServer.tts_resume()
	%CharacterVideoPlayer.set_paused(is_paused)


func _process(delta):
	if GameWorld.paused:
		return
	
	if block_continue > 0.0:
		block_continue -= delta
	
	update_ui(delta)
	if %BriefingPlayer.playing:
		return
	if DisplayServer.tts_is_speaking():
		if not char_is_talking or current_speaker_id != current_teleradio_state.speaker_id:
			current_speaker_id = current_teleradio_state.speaker_id
			char_is_talking = true
			character_video_talk()
	else:
		if char_is_talking:
			char_is_talking = false
			character_video_idle()
			if clear_subtitle_tween:
				clear_subtitle_tween.kill()
			clear_subtitle_tween = create_tween()
			clear_subtitle_tween.tween_callback(clear_subtitle).set_delay(1.7)


func say_sentence():
	if clear_subtitle_tween:
		clear_subtitle_tween.kill()
	var next_sentence = current_teleradio_state.text
	current_sentence_id += 1
	%MainText.text = next_sentence
	var mission_id = Data.ofOr("mission.current_id", "")
	var file_path:String = "res://sounds/VO/" + mission_id + "/" + current_teleradio_state.audio_filename + ".ogg"
	if not ResourceLoader.exists(file_path):
		file_path = "res://sounds/VO/common/" + current_teleradio_state.audio_filename + ".ogg"
	
	if ResourceLoader.exists(file_path):
		%BriefingPlayer.play_line(file_path)
		if not char_is_talking:
			char_is_talking = true
			character_video_talk()
	else:
		Logger.error("Voiceline not found %s" % file_path)
		for v in DisplayServer.tts_get_voices():
			var speaker:TeleradioBriefingSpeaker = speakers[current_teleradio_state.speaker_id]
			if speaker.tts_voice in v.id:
				DisplayServer.tts_speak(next_sentence, v.id, 50, speaker.tts_pitch, speaker.tts_rate)

func clear_subtitle():
	if not char_is_talking:
		MainText.text = ""

func character_video_talk():
	var d := create_tween()
	d.tween_method(control_transition_filter, 0.3, 0.0, randf_range(0.3, 1.0))
	%CharacterVideoPlayer.stream = speakers[current_teleradio_state.speaker_id].talk_streams.pick_random()
	%CharacterVideoPlayer.play()

func character_video_idle():
	var d := create_tween()
	d.tween_method(control_transition_filter, 0.3, 0.0, randf_range(0.3, 1.0))
	if tea_time:
		%CharacterVideoPlayer.stream = speakers[current_teleradio_state.speaker_id].tea_streams.pick_random()
	elif current_teleradio_state:
		var streams = get("character_idle_" + current_teleradio_state.idle_mood + "_streams")
		if streams:
			%CharacterVideoPlayer.stream = streams.pick_random()
		else:
			%CharacterVideoPlayer.stream = speakers[current_teleradio_state.speaker_id].idle_default_streams.pick_random()
	%CharacterVideoPlayer.play()

func control_transition_filter(v:float):
	%TransitionFilter.material.set_shader_parameter("effectIntensity", v)

func _on_character_video_player_finished():
	if char_is_talking:
		character_video_talk()
	else:
		character_video_idle()

func gameDataChanged(property:String, old_value, new_value):
	match property:
		"mission.state":
			match new_value:
				CONST.MISSION_STATE_BRIEFING:
					start_briefing()
				CONST.MISSION_STATE_ACTIVE:
					if current_stage == CALL_STAGE.BRIEFING:
						handle_input("start_mission")
				CONST.MISSION_STATE_DEBRIEFING:
					start_debriefing()
				CONST.MISSION_STATE_TEATIME:
					current_stage = CALL_STAGE.OFF
					update_state()
		"event.drank_tea":
			os.quit_os_app()
			CharacterName.text = ""
			MainText.text = ""
			$ButtonLabels.hide_all()
			return


func show_mission(mission_id:String):
	if not Data.missions.has(mission_id):
		Logger.error("cannot start mission, id `%s` is not known" % mission_id, "Teleradio.show_mission", mission_id)
		return
	Data.apply("mission.current", Data.missions.get(mission_id))
	Data.apply("mission.state", CONST.MISSION_STATE_BRIEFING)


func start_briefing():
	if current_stage != CALL_STAGE.OFF:
		return
	os.ring_begin()
	$IncomingCall/ButtonLabelsIncoming.label_4_visible = true
	current_step = 0
	current_stage = CALL_STAGE.INCOMING
	update_state()
	os.input.disconnect_all_buttons()
	os.input.connect_to(os.input.just_pressed_b1, accept_call_briefing)
	os.input.connect_to(os.input.just_pressed_b4, mute_call)


func start_debriefing():
	if current_stage != CALL_STAGE.OFF:
		return
	os.ring_begin()
	$IncomingCall/ButtonLabelsIncoming.label_4_visible = true
	current_step = 0
	current_stage = CALL_STAGE.INCOMING
	update_state()
	os.input.connect_to(os.input.just_pressed_b1, accept_call_debriefing)
	os.input.connect_to(os.input.just_pressed_b4, mute_call)


func accept_call_briefing():
	os.input.disconnect_all_buttons()
	os.ring_end()
	current_stage = CALL_STAGE.BRIEFING
	update_state()
	say_sentence()


func accept_call_debriefing():
	os.input.disconnect_all_buttons()
	os.ring_end()
	current_stage = CALL_STAGE.DEBRIEFING
	Data.event("event.tea_prepare_sound")
	update_state()
	say_sentence()


func update_state():
	%MissionSummary.hide()
	%MissionResult.hide()
	%UpgradeSelection.hide()
	%FluffLabel.text = BRIEFING_VIDEO_FLUFF % Data.of("mission.current").title
	var choices := []
	var states:Array[TeleradioState]
	match current_stage:
		CALL_STAGE.BRIEFING:
			%IcomingCallAnimation.stop()
			$IncomingCall.hide()
			states = Data.of("mission.current").briefing
			preload_character_resources(states)
		CALL_STAGE.DEBRIEFING:
			%IcomingCallAnimation.stop()
			$IncomingCall.hide()
			states = Data.of("mission.current").debriefing
			preload_character_resources(states)
		CALL_STAGE.DEBRIEF_UPGRADES:
			states = Data.of("mission.current").debriefing_upgrades
			preload_character_resources(states)
		CALL_STAGE.DEBRIEF_TEA:
			states = Data.of("mission.current").debriefing_tea
			preload_character_resources(states)
		CALL_STAGE.INCOMING:
			$IncomingCall.show()
			%IcomingCallAnimation.play("call")
			CharacterName.text = ""
			MainText.text = "Incoming Call"
			return
		CALL_STAGE.OFF:
			if tea_time:
				character_video_idle()
				$ButtonLabels.hide_all()
				MainText.text = ""
				os.input.disconnect_all_buttons()
				return
			else:
				os.quit_os_app()
				CharacterName.text = ""
				MainText.text = ""
				$ButtonLabels.hide_all()
				return
	
	if states.size() >= current_step + 1:
		var state:TeleradioState = states[current_step]
		if state.conditions_fulfilled():
			CharacterName.text = state.name
			current_teleradio_state = state
		else:
			current_step += 1
			update_state()
			return
	
	var reached_end_of_sequence := current_step == states.size() - 1
	if reached_end_of_sequence:
		match current_stage:
			CALL_STAGE.BRIEFING:
				choices.append(["goto_summary", "Summary"])
			CALL_STAGE.DEBRIEFING:
				choices.append(["goto_review", "Performance\nReview"])
			CALL_STAGE.DEBRIEF_UPGRADES:
				choices.append(["goto_upgrades", "Improvement\nSelection"])
			CALL_STAGE.DEBRIEF_TEA:
				choices.append(["finish_mission", "I will drink the Tea"])
	else:
		choices.append(["proceed", ">>"])
	
	if choices.size() < 4:
		for i in 4 - choices.size():
			choices.append(["", ""])
	
	var input_signals := [os.input.just_pressed_b1, os.input.just_pressed_b2, os.input.just_pressed_b3, os.input.just_pressed_b4]
	os.input.disconnect_all_buttons()
	for i in choices.size():
		if choices[i][1] != "":
			$ButtonLabels.set_text(i+1, choices[i][1])
			$ButtonLabels.show_label(i+1)
			os.input.connect_to(input_signals[i], handle_input.bind(choices[i][0]))
		else:
			$ButtonLabels.hide_label(i+1)


func show_summary():
	#OptionLabels[3].text = "Back"
	block_continue = 1.0
	os.input.disconnect_all_buttons()
	%MissionSummary.update_content()


func show_review():
	block_continue = 1.0
	os.input.disconnect_all_buttons()
	%MissionResult.update_content()


func show_upgrades():
	os.input.disconnect_all_buttons()
	%UpgradeSelection.connect_content($ButtonLabels, self)
	%UpgradeSelection.update_content()


func update_ui(delta):
	if %MissionSummary.visible:
		if block_continue <= 0.0:
			$ButtonLabels.label_1 = "Begin"
			os.input.connect_to(os.input.just_pressed_b1, handle_input.bind("start_mission"))
		else:
			$ButtonLabels.label_1 = "Wait (%.0f)" % ceil(block_continue)
	if %MissionResult.visible:
		if block_continue <= 0.0:
			$ButtonLabels.label_1 = "Continue"
			os.input.connect_to(os.input.just_pressed_b1, handle_input.bind("leave_mission_review"))
		else:
			$ButtonLabels.label_1 = "Wait (%.0f)" % ceil(block_continue)


func handle_input(action_id:String):
	#current_stage_sentences.clear()
	DisplayServer.tts_stop()
	%BriefingPlayer.stop_all()
	match action_id:
		"proceed":
			current_sentence_id = 0
			current_step += 1
			update_state()
			say_sentence()
		"goto_summary":
			Data.apply("mission.state", CONST.MISSION_STATE_BRIEFING_DONE)
			current_step = Data.of("mission.current").briefing.size()
			show_summary()
		"goto_review":
			current_stage = CALL_STAGE.DEBRIEFING
			current_step = Data.of("mission.current").debriefing.size() - 1
			show_review()
		"goto_upgrades":
			current_stage = CALL_STAGE.DEBRIEF_UPGRADES
			current_step = Data.of("mission.current").debriefing_upgrades.size() - 1
			show_upgrades()
		"start_mission":
			# Is triggered when the summary screen is closed.
			# But the MISSION_STATE_BRIEFING_DONE was moved to the summary screen
			current_stage = CALL_STAGE.OFF
			update_state()
		"leave_mission_review":
			if not Data.of("upgrades.rewarded") or Data.of("mission.current").debriefing_upgrades.is_empty():
				#skip upgrades
				current_stage = CALL_STAGE.DEBRIEF_UPGRADES
				current_sentence_id = 0
				current_step = 0
				update_state()
				current_stage = CALL_STAGE.DEBRIEF_TEA
			else:
				current_stage = CALL_STAGE.DEBRIEF_UPGRADES
			current_sentence_id = 0
			current_step = 0
			update_state()
			say_sentence()
		"leave_upgrade_screen":
			if Data.of("mission.current").debriefing_tea.is_empty():
				handle_input("finish_mission")
			else:
				current_stage = CALL_STAGE.DEBRIEF_TEA
			current_sentence_id = 0
			current_step = 0
			update_state()
			say_sentence()
		"finish_mission":
			if %UpgradeSelection.selected_upgrade:
				GameWorld.implement_upgrade(%UpgradeSelection.selected_upgrade.id)
			tea_time = true
			Data.event("event.preparetea")
			Data.apply("mission.state", CONST.MISSION_STATE_TEATIME)


func mute_call():
	os.input.disconnect_from(os.input.just_pressed_b4, mute_call)
	$IncomingCall/ButtonLabelsIncoming.label_4_visible = false
	os.ring_end()


func preload_character_resources(states):
	for s:TeleradioState in states:
		speakers[s.speaker_id] = load(SPEAKER_PATH % s.speaker_id)
