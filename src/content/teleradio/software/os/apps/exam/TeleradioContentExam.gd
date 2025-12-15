extends TeleradioContent

signal content_finished
signal loading_finished

var noise:= FastNoiseLite.new()
var question_index := -1
var selected_question := -1

var score := 0

var loading_progress:= 200.0
var loading_speed := 70.0
var is_loading:= false

var exam_id := "advanced_mechanist"
var exam : Dictionary
var questions : Array


func _ready():
	if content_parameters.has("exam_id"):
		exam_id = content_parameters.exam_id
	exam = CONST.EXAMS[exam_id]
	questions = exam.questions
	
	show_question(question_index)
	connect_back_button()


func _process(delta):
	if loading_progress < 110.0:
		loading(delta)
	if loading_progress >= 100.0:
		if is_loading:
			loading_speed = 400.0
			is_loading = false
			os.stop_load_sound()
			loading_finished.emit()
	$ResultOverlay/CalcNode1.visible = loading_progress < 104.0
	$ResultOverlay/CalcNode2.visible = loading_progress < 104.0


func loading(delta):
	var new_progress = delta*loading_speed
	if loading_progress <= 100.0:
		new_progress = delta*max(0.0, noise.get_noise_1d(float(Time.get_ticks_msec())/100.0)+0.5)*loading_speed
		if loading_progress > 90.0:
			new_progress *= 0.05
		elif loading_progress > 80.0:
			new_progress *= 0.3
	loading_progress += new_progress
	%LoadingBar.value = loading_progress


func calculate_result():
	%ResultOverlay.show()
	os.start_load_sound()
	is_loading = true
	os.input.disconnect_all_buttons()
	loading_progress = -20.0


func connect_default_buttons():
	$ButtonLabels.label_1_visible = true
	$ButtonLabels.label_2_visible = true
	$ButtonLabels.label_3_visible = true
	os.input.connect_button1(button_1_pressed)
	os.input.connect_button2(button_2_pressed)
	os.input.connect_button3(button_3_pressed)


func connect_back_button():
	$ButtonLabels.label_4_visible = true
	os.input.connect_button4(button_back_pressed)


func show_question(index:int):
	if index == -1:
		os.input.connect_button1(button_1_pressed)
		%Headline.text = exam.title + ": Welcome"
		%Question.text = exam.intro
		$ButtonLabels.label_1 = "Begin"
		$ButtonLabels.label_1_visible = true
		$ButtonLabels.label_2_visible = false
		$ButtonLabels.label_3_visible = false
		%Answer1.hide()
		%Answer2.hide()
		%Answer3.hide()
	elif index < questions.size():
		connect_default_buttons()
		%Headline.text = "%s: Question %s" % [exam.title, index+1]
		%Question.text = questions[index].question
		if selected_question == 1:
			$ButtonLabels.label_1 = "Confirm 1"
			%Answer1.text = ">1)" + questions[index].answers[0]
		else:
			$ButtonLabels.label_1 = "Select 1"
			%Answer1.text = " 1)" + questions[index].answers[0]
		if selected_question == 2:
			$ButtonLabels.label_2 = "Confirm 2"
			%Answer2.text = ">2)" + questions[index].answers[1]
		else:
			$ButtonLabels.label_2 = "Select 2"
			%Answer2.text = " 2)" + questions[index].answers[1]
		if selected_question == 3:
			$ButtonLabels.label_3 = "Confirm 3"
			%Answer3.text = ">3)" + questions[index].answers[2]
		else:
			$ButtonLabels.label_3 = "Select 3"
			%Answer3.text = " 3)" + questions[index].answers[2]
		%Answer1.show()
		%Answer2.show()
		%Answer3.show()
	else:
		calculate_result()


func send_answer(answer_id:int):
	if questions[question_index].correct == answer_id:
		score += 1
	selected_question = -1
	question_index += 1
	show_question(question_index)


func button_1_pressed():
	if question_index == -1:
		question_index += 1
		show_question(question_index)
		return
	if selected_question != 1:
		selected_question = 1
		show_question(question_index)
	else:
		send_answer(1)

func button_2_pressed():
	if selected_question != 2:
		selected_question = 2
		show_question(question_index)
	else:
		send_answer(2)

func button_3_pressed():
	if selected_question != 3:
		selected_question = 3
		show_question(question_index)
	else:
		send_answer(3)

func button_back_pressed():
	os.quit_app(true)

func _on_loading_finished():
	await create_tween().tween_interval(0.8).finished
	%ResultPresentation.show()
	await create_tween().tween_interval(1.0).finished
	var total = questions.size()
	%Result1.text = "%s/%s" % [score, total]
	%Result1.show()
	await create_tween().tween_interval(0.5).finished
	if score >= total * 0.8:
		$ExamSuccessSound.play()
		%Result2.text = "Passed!"
	else:
		$ExamFailSound.play()
		%Result2.text = "Failed!"
	%Result2.show()
	%ResultExitOption.show()
	await create_tween().tween_interval(1.0).finished
	%RewardText.text = exam.outro
	%RewardText.show()
	os.input.connect_button1(button_back_pressed)
