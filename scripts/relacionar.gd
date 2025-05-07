extends Control

@onready var buttons := $GridContainerWords.get_children()
@onready var progress = $ProgressBar

var selected_words := []
var word_matches := {}

func _ready():
	for button in buttons:
		button.pressed.connect(self._on_word_pressed.bind(button))

	_load_words_for_level(1)

func _on_word_pressed(button):
	if button in selected_words:
		selected_words.erase(button)
		button.remove_theme_color_override("font_color")
	else:
		if selected_words.size() < 2:
			selected_words.append(button)
			button.add_theme_color_override("font_color", Color.ORANGE)

		# Verificar automáticamente si hay 2 seleccionados
		if selected_words.size() == 2:
			var word1 = selected_words[0].text
			var word2 = selected_words[1].text

			if _check_match(word1, word2):
				for btn in selected_words:
					btn.disabled = true
				progress.value += 10
			else:
				for btn in selected_words:
					btn.add_theme_color_override("font_color", Color.RED)

			await get_tree().create_timer(0.5).timeout  # Espera medio segundo antes de limpiar
			for btn in selected_words:
				btn.remove_theme_color_override("font_color")

			selected_words.clear()

func _check_match(word1: String, word2: String) -> bool:
	return word_matches.get(word1, "") == word2 or word_matches.get(word2, "") == word1

func _load_words_for_level(level: int):
	word_matches = {
		"Alla": "Ompa",
		"Aquel": "Inon",
		"Bueno": "Cualli",
		"Despues": "Zatepan",
		"Donde": "Campa",
	}

	var words = word_matches.keys() + word_matches.values()
	words.shuffle()

	for i in range(buttons.size()):
		if i < words.size():
			buttons[i].text = words[i]
			buttons[i].disabled = false
		else:
			buttons[i].text = ""
			buttons[i].disabled = true
