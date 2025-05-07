extends Control

@onready var btn_back1 = $ButtonBack1
@onready var btn_topic = $TextureButtonTopic
@onready var btn_start = $TextureButtonStart
# Called when the node enters the scene tree for the first time.
func _ready():
	btn_back1.pressed.connect(_on_back_pressed1)
	btn_topic.pressed.connect(self._on_topic_pressed)
	btn_start.pressed.connect(self._on_start_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_back_pressed1():
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
	
func _on_topic_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/topic/modulo1temas.tscn")

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/activities/relacionar.tscn")
