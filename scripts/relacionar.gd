extends Control
@onready var vbox_esp = $GridContainerWords/VBoxEsp
@onready var vbox_nau = $GridContainerWords/VBoxNau
@onready var progress = $ProgressBar

var selected_words := []
var word_matches := {}
var buttons_esp := []
var buttons_nau := []

func _ready():
	_load_words_from_csv("res://data/adverbios.txt")
	_create_buttons()

func _create_buttons():
	# Limpiar botones anteriores
	for btn in buttons_esp:
		btn.queue_free()
	for btn in buttons_nau:
		btn.queue_free()
	buttons_esp.clear()
	buttons_nau.clear()
	selected_words.clear()

	# Crear botones para español
	for esp_word in word_matches.keys():
		var btn = Button.new()
		btn.text = esp_word
		btn.disabled = false
		btn.pressed.connect(Callable(self, "_on_word_pressed").bind(btn))
		vbox_esp.add_child(btn)
		buttons_esp.append(btn)

	# Crear botones para náhuatl
	for nau_word in word_matches.values():
		var btn = Button.new()
		btn.text = nau_word
		btn.disabled = false
		btn.pressed.connect(Callable(self, "_on_word_pressed").bind(btn))
		vbox_nau.add_child(btn)
		buttons_nau.append(btn)

func _on_word_pressed(button):
	if button in selected_words:
		selected_words.erase(button)
		button.remove_theme_color_override("font_color")
	else:
		if selected_words.size() < 2:
			selected_words.append(button)
			button.add_theme_color_override("font_color", Color.ORANGE)

		if selected_words.size() == 2:
			var word1 = selected_words[0].text
			var word2 = selected_words[1].text

			if _check_match(word1, word2):
				for btn in selected_words:
					btn.disabled = true
				progress.value += 100.0 / word_matches.size()
			else:
				for btn in selected_words:
					btn.add_theme_color_override("font_color", Color.RED)

			await get_tree().create_timer(0.5).timeout
			for btn in selected_words:
				btn.remove_theme_color_override("font_color")

			selected_words.clear()

func _check_match(word1: String, word2: String) -> bool:
	return word_matches.get(word1, "") == word2 or word_matches.get(word2, "") == word1

func _load_words_from_csv(file_path: String):
	word_matches.clear()

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("No se pudo abrir el archivo: ", file_path)
		return

	var is_header := true
	while not file.eof_reached():
		var line = file.get_line()
		if is_header:
			is_header = false
			continue  # Salta encabezado

		var columns = line.split(",", false)
		if columns.size() >= 4:
			var esp = columns[2].strip_edges()
			var nau = columns[3].strip_edges()
			word_matches[esp] = nau
	file.close()
