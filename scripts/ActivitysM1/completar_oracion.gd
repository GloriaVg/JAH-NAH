extends Control

@onready var titulo_label = $MarginContainer/VBoxContainer/TituloLabel
@onready var audio_normal_button = $MarginContainer/VBoxContainer/AudioContainer/AudioNormalButton
@onready var audio_lento_button = $MarginContainer/VBoxContainer/AudioContainer/AudioLentoButton
@onready var oracion_container = $MarginContainer/VBoxContainer/OracionContainer
@onready var oracion_label = $MarginContainer/VBoxContainer/OracionContainer/Label
@onready var palabra_button = $MarginContainer/VBoxContainer/OracionContainer/PalabraButton
@onready var oracion_label2 = $MarginContainer/VBoxContainer/OracionContainer/Label2
@onready var opciones_container = $MarginContainer/VBoxContainer/OpcionesContainer
@onready var verificar_button = $MarginContainer/VBoxContainer/VerificarButton

var datos = []
var oracion_actual = {}
var palabra_seleccionada = ""
var respuesta_correcta = ""
var indice_palabra_oculta = 0
var frase_nahuatl = ""
var frase_espanol = ""

func _ready():
	randomize()
	titulo_label.text = "Xikajxitili in tlajtoli"
	verificar_button.disabled = true
	cargar_datos()
	conectar_senales()

func conectar_senales():
	verificar_button.pressed.connect(verificar_respuesta)
	audio_normal_button.pressed.connect(reproducir_audio_normal)
	audio_lento_button.pressed.connect(reproducir_audio_lento)

	for opcion in opciones_container.get_children():
		opcion.pressed.connect(_on_opcion_pressed.bind(opcion))

func cargar_datos():
	var ruta = "res://datos/saludos.json"
	if not FileAccess.file_exists(ruta):
		printerr("❌ Archivo no encontrado: ", ruta)
		return

	var file = FileAccess.open(ruta, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())

	if parsed:
		# Filtrar solo las entradas que tienen el formato necesario
		datos = parsed.filter(func(item): 
			return item.has("nahuatl") and item.has("espanol") and item.get("nahuatl", "").split(" ").size() > 1
		)
		print("✅ Datos cargados correctamente: ", datos.size(), " oraciones")
		if datos.size() > 0:
			preparar_siguiente_oracion()
		else:
			printerr("❌ No se encontraron oraciones válidas para completar")
	else:
		printerr("❌ Error al parsear JSON")

func preparar_siguiente_oracion():
	if datos.is_empty():
		printerr("❌ No hay oraciones disponibles")
		return

	palabra_seleccionada = ""
	verificar_button.disabled = true
	palabra_button.text = "____"

	# Seleccionar una oración aleatoria
	var indice_aleatorio = randi() % datos.size()
	oracion_actual = datos[indice_aleatorio]
	frase_nahuatl = oracion_actual.get("nahuatl", "")
	frase_espanol = oracion_actual.get("espanol", "")

	titulo_label.text = frase_espanol

	var palabras = []
	for p in frase_nahuatl.split(" ", false):
		var clean = p.strip_edges()
		if clean != "":
			palabras.append(clean)

	var palabras_validas = palabras.filter(func(p): return p.length() > 2)

	if palabras_validas.is_empty():
		indice_palabra_oculta = randi() % palabras.size()
	else:
		var palabra_elegida = palabras_validas[randi() % palabras_validas.size()]
		indice_palabra_oculta = palabras.find(palabra_elegida)

	respuesta_correcta = palabras[indice_palabra_oculta]
	_actualizar_oracion_con_palabra("____")
	generar_opciones()

func generar_opciones():
	var opciones = [respuesta_correcta]
	var palabras_similares = []

	for frase in datos:
		for palabra in frase["nahuatl"].split(" "):
			palabra = palabra.strip_edges()
			if palabra != respuesta_correcta and palabra.length() > 2:
				if abs(palabra.length() - respuesta_correcta.length()) <= 2 and not palabras_similares.has(palabra):
					palabras_similares.append(palabra)

	if palabras_similares.size() < 3:
		for frase in datos:
			for palabra in frase["nahuatl"].split(" "):
				palabra = palabra.strip_edges()
				if palabra != respuesta_correcta and palabra.length() > 2 and not palabras_similares.has(palabra):
					palabras_similares.append(palabra)

	var max_opciones = min(3, palabras_similares.size())
	while opciones.size() < 4 and palabras_similares.size() > 0:
		var index = randi() % palabras_similares.size()
		opciones.append(palabras_similares[index])
		palabras_similares.remove_at(index)

	var opciones_mezcladas = []
	while not opciones.is_empty():
		var index = randi() % opciones.size()
		opciones_mezcladas.append(opciones[index])
		opciones.remove_at(index)

	for i in range(opciones_container.get_child_count()):
		var boton := opciones_container.get_child(i)
		boton.text = opciones_mezcladas[i] if i < opciones_mezcladas.size() else ""
		boton.modulate = Color.WHITE
		boton.disabled = false

func _actualizar_oracion_con_palabra(palabra: String) -> void:
	var palabras = frase_nahuatl.split(" ")
	
	# Actualizar el texto antes del botón
	var texto_antes = ""
	for i in range(indice_palabra_oculta):
		texto_antes += palabras[i].strip_edges() + " "
	oracion_label.text = texto_antes.strip_edges()
	
	# Actualizar el botón
	palabra_button.text = palabra.strip_edges()
	
	# Actualizar el texto después del botón
	var texto_despues = ""
	for i in range(indice_palabra_oculta + 1, palabras.size()):
		texto_despues += palabras[i].strip_edges() + " "
	oracion_label2.text = texto_despues.strip_edges()

func _on_opcion_pressed(opcion_button: Button):
	palabra_seleccionada = opcion_button.text
	palabra_button.text = palabra_seleccionada
	verificar_button.disabled = false
	
	# Resetear colores
	palabra_button.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	
	for opcion in opciones_container.get_children():
		opcion.modulate = Color.WHITE
	opcion_button.modulate = Color(0.8, 0.8, 1.0)

func verificar_respuesta():
	var correcto = palabra_seleccionada == respuesta_correcta
	
	if correcto:
		palabra_button.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))  # Verde
		for opcion in opciones_container.get_children():
			opcion.disabled = true
		
		verificar_button.disabled = true
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://scenes/ACTIVIDADESM1/OpcionMultiple.tscn")
	else:
		palabra_button.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))  # Rojo
		await get_tree().create_timer(1.0).timeout
		reset_respuesta()

func reset_respuesta():
	palabra_button.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	palabra_button.text = "____"
	palabra_seleccionada = ""
	verificar_button.disabled = true
	
	for opcion in opciones_container.get_children():
		opcion.modulate = Color.WHITE
		opcion.disabled = false

func reproducir_audio_normal():
	if oracion_actual.has("audio"):
		print("🔊 Reproduciendo audio normal")

func reproducir_audio_lento():
	if oracion_actual.has("audio"):
		print("🐢 Reproduciendo audio lento")
