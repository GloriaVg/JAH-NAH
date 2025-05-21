extends Control

@onready var phrase_label: Label = $Label
@onready var word_buttons: Array = $GridContainer.get_children()
@onready var next_button: Button = $VBoxContainer/Button
@onready var progress_bar: = $ProgressBar 

var correct_phrase := ["El", "gato", "negro", "salta"]
var current_phrase := []

func _ready():
	var shuffled_words = correct_phrase.duplicate()
	shuffled_words.shuffle()

	for i in word_buttons.size():
		word_buttons[i].text = shuffled_words[i]
		word_buttons[i].disabled = false
		word_buttons[i].pressed.connect(func(): _on_word_pressed(word_buttons[i]))

func _on_word_pressed(btn: Button):
	var word = btn.text
	current_phrase.append(word)
	phrase_label.text = " ".join(current_phrase)
	btn.disabled = true  # evita que el mismo botón se use más de una vez

	# Validar automáticamente cuando la longitud coincida
	if current_phrase.size() == correct_phrase.size():
		_validate_phrase()

func _validate_phrase():
	if current_phrase == correct_phrase:
		phrase_label.text += " ✅ ¡Frase correcta!"
		progress_bar.value += 100
	else:
		phrase_label.text += " ❌ Frase incorrecta"

func _on_next_pressed():
	# Reinicia todo
	current_phrase.clear()
	phrase_label.text = ""

	var shuffled_words = correct_phrase.duplicate()
	shuffled_words.shuffle()

	for i in word_buttons.size():
		word_buttons[i].text = shuffled_words[i]
		word_buttons[i].disabled = false
