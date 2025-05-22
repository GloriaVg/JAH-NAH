extends Node

var current_module = null
var current_lesson = null
var current_exercise = null
var score = 0
var exercises_completed = 0

func _ready():
	load_module(2)  # Cargamos el módulo 2 por defecto

func load_module(module_id: int) -> void:
	var path = "res://assets/lessons/module" + str(module_id) + ".json"
	
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK:
			current_module = json.get_data()
			print("Módulo cargado: ", current_module.module_name)
		else:
			print("Error al cargar el módulo: ", json.get_error_message())
	else:
		print("No se encontró el archivo del módulo")

func start_lesson(lesson_id: String) -> void:
	for lesson in current_module.lessons:
		if lesson.lesson_id == lesson_id:
			current_lesson = lesson
			exercises_completed = 0
			score = 0
			print("Iniciando lección: ", lesson.lesson_name)
			return
	print("Lección no encontrada")

func get_next_exercise() -> Dictionary:
	if current_lesson and exercises_completed < current_lesson.exercises.size():
		current_exercise = current_lesson.exercises[exercises_completed]
		return current_exercise
	return {}

func check_answer(answer: String) -> bool:
	if not current_exercise:
		return false
		
	var is_correct = false
	match current_exercise.type:
		"multiple_choice":
			is_correct = answer == current_exercise.correct_answer
		"translation":
			is_correct = answer.to_lower().strip_edges() == current_exercise.answer.to_lower().strip_edges()
	
	if is_correct:
		score += 10
		exercises_completed += 1
	
	return is_correct

func get_progress() -> Dictionary:
	return {
		"score": score,
		"exercises_completed": exercises_completed,
		"total_exercises": current_lesson.exercises.size() if current_lesson else 0
	} 
