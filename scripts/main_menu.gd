extends Control

var lesson_manager

func _ready():
	lesson_manager = get_node("/root/LessonManager")
	setup_connections()

func setup_connections():
	$VBoxContainer/Lesson2_1.pressed.connect(_on_lesson_2_1_pressed)
	$VBoxContainer/Lesson2_2.pressed.connect(_on_lesson_2_2_pressed)
	$VBoxContainer/Lesson2_3.pressed.connect(_on_lesson_2_3_pressed)

func _on_lesson_2_1_pressed():
	lesson_manager.start_lesson("2.1")
	get_tree().change_scene_to_file("res://scenes/lesson_scene.tscn")

func _on_lesson_2_2_pressed():
	lesson_manager.start_lesson("2.2")
	get_tree().change_scene_to_file("res://scenes/lesson_scene.tscn")

func _on_lesson_2_3_pressed():
	lesson_manager.start_lesson("2.3")
	get_tree().change_scene_to_file("res://scenes/lesson_scene.tscn")
