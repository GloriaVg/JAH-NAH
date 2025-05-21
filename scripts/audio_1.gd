extends Control

@onready var progress_bar := $MarginContainer/VBoxContainer/HBoxContainer/ProgressBar
@onready var play_button := $Button
@onready var options := $MarginContainer/VBoxContainer/HBoxContainer/GridContainer.get_children()
@onready var audio_player := AudioStreamPlayer.new()

var current_answer = ""
var current_options = []
var correct_image_path = ""
var question_data = [
	{
		"audio": "res://assets/audio/gato.ogg",
		"correct": "res://assets/images/gato.png",
		"options": [
			"res://assets/images/gato.png",
			"res://assets/images/perro.png",
			"res://assets/images/pez.png",
			"res://assets/images/pajaro.png",
		]
	},
	# Agrega más preguntas aquí...
]

func _ready():
	add_child(audio_player)
	play_button.pressed.connect(_play_audio)
	load_question(0)

	for button in options:
		button.pressed.connect(self._on_option_selected.bind(button))

func load_question(index: int):
	var q = question_data[index]
	current_answer = q.correct
	current_options = q.options.duplicate()
	current_options.shuffle()

	for i in range(options.size()):
		options[i].texture_normal = load(current_options[i])
		options[i].disabled = false

	audio_player.stream = load(q.audio)
	_play_audio()

func _play_audio():
	audio_player.play()

func _on_option_selected(button):
	if button.texture_normal.resource_path == current_answer:
		progress_bar.value += 20
		button.modulate = Color.GREEN
	else:
		button.modulate = Color.RED

	await get_tree().create_timer(1.0).timeout
	button.modulate = Color.WHITE
