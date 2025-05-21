extends Control

@onready var phrase_label: Label = $Label
@onready var word_buttons: Array = $GridContainer.get_children()

# Lista de preguntas, cada una con la frase y la palabra faltante
var questions = [
	{
		"phrase": "El gato ___ en el tejado.",
		"correct": "duerme",
		"options": ["duerme", "corre", "ladra", "nada"]
	},
]

var current_index = 0
var current_question = {}

func _ready():
	for btn in word_buttons:
		btn.pressed.connect(func(): _on_option_pressed(btn))
	load_question(current_index)

func load_question(index):
	current_question = questions[index]
	phrase_label.text = current_question.phrase

	var shuffled = current_question.options.duplicate()
	shuffled.shuffle()

	for i in word_buttons.size():
		word_buttons[i].text = shuffled[i]
		word_buttons[i].disabled = false

func _on_option_pressed(btn: Button):
	var selected_word = btn.text
	if selected_word == current_question.correct:
		phrase_label.text = current_question.phrase.replace("___", selected_word) + " ✅ ¡Correcto!"
	else:
		phrase_label.text = current_question.phrase.replace("___", selected_word) + " ❌ Incorrecto"
	for btnn in word_buttons:
		btnn.disabled = true

func _on_next_pressed():
	current_index = (current_index + 1) % questions.size()
	load_question(current_index)
