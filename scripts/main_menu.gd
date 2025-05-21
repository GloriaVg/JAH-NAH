extends Control

@onready var btn_start = $VBoxContainer/ButtonStart

func _ready():
	btn_start.pressed.connect(_on_start_pressed)


func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
