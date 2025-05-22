extends Control

var lesson_manager
var current_exercise = null
var match_selected = {}
var order_sequence_user = []

func _ready():
	lesson_manager = get_node("/root/LessonManager")
	setup_connections()
	load_next_exercise()

func setup_connections():
	$VBoxContainer/QuestionContainer/OptionsContainer/Option1.pressed.connect(_on_option1_pressed)
	$VBoxContainer/QuestionContainer/OptionsContainer/Option2.pressed.connect(_on_option2_pressed)
	$VBoxContainer/QuestionContainer/OptionsContainer/Option3.pressed.connect(_on_option3_pressed)
	$VBoxContainer/QuestionContainer/OptionsContainer/Option4.pressed.connect(_on_option4_pressed)
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	# Para respuestas escritas
	if $VBoxContainer/QuestionContainer.has_node("AnswerInput"):
		$VBoxContainer/QuestionContainer/AnswerInput.text_submitted.connect(_on_answer_input_submitted)

func _on_option1_pressed():
	_on_option_selected(0)

func _on_option2_pressed():
	_on_option_selected(1)

func _on_option3_pressed():
	_on_option_selected(2)

func _on_option4_pressed():
	_on_option_selected(3)

func load_next_exercise():
	current_exercise = lesson_manager.get_next_exercise()
	
	if current_exercise.is_empty():
		show_completion()
		return
	
	update_ui()

func update_ui():
	$VBoxContainer/LessonTitle.text = lesson_manager.current_lesson.lesson_name
	$VBoxContainer/Feedback.text = ""
	$VBoxContainer/QuestionContainer/Question.text = current_exercise.question
	$VBoxContainer/QuestionContainer/OptionsContainer.visible = false
	if $VBoxContainer/QuestionContainer.has_node("AnswerInput"):
		$VBoxContainer/QuestionContainer/AnswerInput.visible = false
	if $VBoxContainer/QuestionContainer.has_node("MatchContainer"):
		$VBoxContainer/QuestionContainer/MatchContainer.visible = false
	if $VBoxContainer/QuestionContainer.has_node("OrderContainer"):
		$VBoxContainer/QuestionContainer/OrderContainer.visible = false

	match current_exercise.type:
		"multiple_choice":
			show_multiple_choice()
		"fill_in_blank", "write_number":
			show_answer_input()
		"match":
			show_match()
		"order_sequence":
			show_order_sequence()

	var progress = lesson_manager.get_progress()
	$VBoxContainer/Progress.text = "Progreso: %d/%d" % [progress.exercises_completed, progress.total_exercises]
	$VBoxContainer/Score.text = "Puntuación: %d" % progress.score

func show_multiple_choice():
	$VBoxContainer/QuestionContainer/OptionsContainer.visible = true
	var options = current_exercise.options
	for i in range(4):
		var option_button = get_node("VBoxContainer/QuestionContainer/OptionsContainer/Option" + str(i + 1))
		option_button.text = options[i]
		option_button.visible = i < options.size()

func show_answer_input():
	var input_node
	if $VBoxContainer/QuestionContainer.has_node("AnswerInput"):
		input_node = $VBoxContainer/QuestionContainer/AnswerInput
	else:
		input_node = LineEdit.new()
		input_node.name = "AnswerInput"
		$VBoxContainer/QuestionContainer.add_child(input_node)
		input_node.text_submitted.connect(_on_answer_input_submitted)
	input_node.text = ""
	input_node.visible = true
	input_node.grab_focus()

func _on_answer_input_submitted(text):
	var correct = false
	if current_exercise.type == "fill_in_blank" or current_exercise.type == "write_number":
		correct = text.strip_edges().to_lower() == current_exercise.answer.strip_edges().to_lower()
	show_feedback_and_next(correct, current_exercise.explanation, current_exercise.answer)

func show_match():
	var match_container
	if $VBoxContainer/QuestionContainer.has_node("MatchContainer"):
		match_container = $VBoxContainer/QuestionContainer/MatchContainer
		match_container.visible = true
		for child in match_container.get_children():
			child.queue_free()
	else:
		match_container = VBoxContainer.new()
		match_container.name = "MatchContainer"
		$VBoxContainer/QuestionContainer.add_child(match_container)
	match_selected = {}
	var pairs = current_exercise.pairs
	var es_list = []
	var nah_list = []
	for pair in pairs:
		es_list.append(pair["es"])
		nah_list.append(pair["nah"])
	nah_list.shuffle()
	for i in range(es_list.size()):
		var hbox = HBoxContainer.new()
		var label = Label.new()
		label.text = es_list[i]
		hbox.add_child(label)
		var option = OptionButton.new()
		for n in nah_list:
			option.add_item(n)
		option.selected = -1
		var es_val = es_list[i]
		option.connect("item_selected", func(idx): _on_match_selected(idx, es_val, option))
		hbox.add_child(option)
		match_container.add_child(hbox)
	var submit_btn = Button.new()
	submit_btn.text = "Comprobar"
	submit_btn.pressed.connect(_on_match_submit)
	match_container.add_child(submit_btn)

func _on_match_selected(idx, es_text, option):
	match_selected[es_text] = option.get_item_text(idx)

func _on_match_submit():
	var correct = true
	for pair in current_exercise.pairs:
		if !match_selected.has(pair["es"]) or match_selected[pair["es"]] != pair["nah"]:
			correct = false
			break
	show_feedback_and_next(correct, current_exercise.explanation, "")

func show_order_sequence():
	var order_container
	if $VBoxContainer/QuestionContainer.has_node("OrderContainer"):
		order_container = $VBoxContainer/QuestionContainer/OrderContainer
		order_container.visible = true
		for child in order_container.get_children():
			child.queue_free()
	else:
		order_container = VBoxContainer.new()
		order_container.name = "OrderContainer"
		$VBoxContainer/QuestionContainer.add_child(order_container)
	order_sequence_user = current_exercise.sequence.duplicate()
	order_sequence_user.shuffle()
	for i in range(order_sequence_user.size()):
		var btn = Button.new()
		btn.text = order_sequence_user[i]
		var idx = i
		btn.pressed.connect(func(): _on_order_btn_pressed(idx))
		order_container.add_child(btn)
	var submit_btn = Button.new()
	submit_btn.text = "Comprobar"
	submit_btn.pressed.connect(_on_order_submit)
	order_container.add_child(submit_btn)

func _on_order_btn_pressed(idx):
	# Intercambia el botón presionado con el siguiente (básico)
	if idx < order_sequence_user.size() - 1:
		var temp = order_sequence_user[idx]
		order_sequence_user[idx] = order_sequence_user[idx + 1]
		order_sequence_user[idx + 1] = temp
		show_order_sequence()

func _on_order_submit():
	var correct = order_sequence_user == current_exercise.sequence
	show_feedback_and_next(correct, current_exercise.explanation, "")

func _on_option_selected(option_index: int):
	var selected_answer = current_exercise.options[option_index]
	var correct = lesson_manager.check_answer(selected_answer)
	show_feedback_and_next(correct, current_exercise.explanation, current_exercise.correct_answer)

func show_feedback_and_next(correct, explanation, correct_answer):
	if correct:
		$VBoxContainer/Feedback.text = "¡Correcto! " + explanation
		$VBoxContainer/Feedback.add_theme_color_override("font_color", Color(0, 1, 0))
	else:
		var msg = "Incorrecto. "
		if correct_answer != "":
			msg += "La respuesta correcta era: " + correct_answer + ". "
		msg += explanation
		$VBoxContainer/Feedback.text = msg
		$VBoxContainer/Feedback.add_theme_color_override("font_color", Color(1, 0, 0))
	await get_tree().create_timer(2.0).timeout
	load_next_exercise()

func show_completion():
	$VBoxContainer/QuestionContainer/Question.text = "¡Lección Completada!"
	$VBoxContainer/QuestionContainer/OptionsContainer.visible = false
	if $VBoxContainer/QuestionContainer.has_node("AnswerInput"):
		$VBoxContainer/QuestionContainer/AnswerInput.visible = false
	if $VBoxContainer/QuestionContainer.has_node("MatchContainer"):
		$VBoxContainer/QuestionContainer/MatchContainer.visible = false
	if $VBoxContainer/QuestionContainer.has_node("OrderContainer"):
		$VBoxContainer/QuestionContainer/OrderContainer.visible = false
	$VBoxContainer/Feedback.text = "¡Felicidades! Has completado la lección."

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn") 
