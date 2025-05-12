extends Control

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/start/Welcome.tscn")

func _ready():
	$AnimationPlayer.play("fade_and_change") 

func change_scene():
	get_tree().change_scene_to_file("res://scenes/start/Welcome.tscn")
