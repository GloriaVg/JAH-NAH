extends Control

@onready var titulo_label = $MarginContainer/VBoxContainer/TituloLabel
@onready var progress_bar = $MarginContainer/VBoxContainer/ProgressBar
@onready var pares_container = $MarginContainer/VBoxContainer/ParesContainer
@onready var comprobar_button = $MarginContainer/VBoxContainer/ComprobarButton

var datos = []
var pares_actuales = []
var selecciones = {}
var ultimo_audio_seleccionado = null
var ultimo_texto_seleccionado = null

func _ready():
	randomize()
	comprobar_button.disabled = true
	cargar_datos()
	conectar_senales()

func conectar_senales():
	comprobar_button.pressed.connect(verificar_respuestas)
	
	for par in pares_container.get_children():
		var audio_button = par.get_node("HBoxContainer/AudioButton")
		var texto_button = par.get_node("HBoxContainer/TextoButton")
		
		audio_button.pressed.connect(_on_audio_pressed.bind(audio_button))
		texto_button.pressed.connect(_on_texto_pressed.bind(texto_button))

func cargar_datos():
	var ruta = "res://datos/saludos.json"
	if not FileAccess.file_exists(ruta):
		printerr("❌ Archivo no encontrado: ", ruta)
		return

	var file = FileAccess.open(ruta, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())

	if parsed:
		datos = parsed.filter(func(item): 
			return item.has("nahuatl") and item.has("espanol")
		)
		print("✅ Datos cargados correctamente: ", datos.size(), " frases")
		if datos.size() >= 4:
			preparar_siguiente_ronda()
		else:
			printerr("❌ No hay suficientes frases para generar pares")
	else:
		printerr("❌ Error al parsear JSON")

func preparar_siguiente_ronda():
	selecciones.clear()
	ultimo_audio_seleccionado = null
	ultimo_texto_seleccionado = null
	comprobar_button.disabled = true

	# Seleccionar 4 frases aleatorias
	datos.shuffle()
	pares_actuales = datos.slice(0, 4)
	
	# Crear arrays separados para audio y texto
	var textos = pares_actuales.map(func(item): return item.get("nahuatl"))
	textos.shuffle()
	
	# Asignar a los botones
	for i in range(pares_container.get_child_count()):
		var par = pares_container.get_child(i)
		var audio_button = par.get_node("HBoxContainer/AudioButton")
		var texto_button = par.get_node("HBoxContainer/TextoButton")
		
		audio_button.text = "🔊"
		texto_button.text = textos[i]
		
		# Resetear estados visuales
		audio_button.modulate = Color.WHITE
		texto_button.modulate = Color.WHITE
		audio_button.disabled = false
		texto_button.disabled = false

func _on_audio_pressed(button):
	if ultimo_audio_seleccionado == button:
		button.modulate = Color.WHITE
		ultimo_audio_seleccionado = null
	else:
		if ultimo_audio_seleccionado:
			ultimo_audio_seleccionado.modulate = Color.WHITE
		button.modulate = Color(0.8, 0.8, 1.0)
		ultimo_audio_seleccionado = button
		reproducir_audio(button)
	
	verificar_seleccion()

func _on_texto_pressed(button):
	if ultimo_texto_seleccionado == button:
		button.modulate = Color.WHITE
		ultimo_texto_seleccionado = null
	else:
		if ultimo_texto_seleccionado:
			ultimo_texto_seleccionado.modulate = Color.WHITE
		button.modulate = Color(0.8, 0.8, 1.0)
		ultimo_texto_seleccionado = button
	
	verificar_seleccion()

func verificar_seleccion():
	if ultimo_audio_seleccionado and ultimo_texto_seleccionado:
		var audio_index = ultimo_audio_seleccionado.get_parent().get_parent().get_index()
		var texto = ultimo_texto_seleccionado.text
		
		selecciones[audio_index] = texto
		
		ultimo_audio_seleccionado.modulate = Color.WHITE
		ultimo_texto_seleccionado.modulate = Color.WHITE
		ultimo_audio_seleccionado.disabled = true
		ultimo_texto_seleccionado.disabled = true
		
		ultimo_audio_seleccionado = null
		ultimo_texto_seleccionado = null
		
		comprobar_button.disabled = selecciones.size() < 4

func verificar_respuestas():
	var todas_correctas = true
	var pares_correctos = 0
	
	for audio_index in selecciones:
		var texto_seleccionado = selecciones[audio_index]
		var texto_correcto = pares_actuales[audio_index].get("nahuatl")
		
		var par = pares_container.get_child(audio_index)
		var texto_button = par.get_node("HBoxContainer/TextoButton")
		
		if texto_seleccionado == texto_correcto:
			texto_button.modulate = Color(0.2, 0.8, 0.2)  # Verde
			pares_correctos += 1
		else:
			texto_button.modulate = Color(0.8, 0.2, 0.2)  # Rojo
			todas_correctas = false
	
	progress_bar.value = (pares_correctos / 4.0) * 100
	
	if todas_correctas:
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://scenes/ACTIVIDADESM1/CompletarOracion.tscn")
	else:
		await get_tree().create_timer(1.0).timeout
		preparar_siguiente_ronda()

func reproducir_audio(button):
	var index = button.get_parent().get_parent().get_index()
	var frase = pares_actuales[index]
	if frase.has("audio"):
		print("🔊 Reproduciendo audio: ", frase.get("nahuatl")) 
