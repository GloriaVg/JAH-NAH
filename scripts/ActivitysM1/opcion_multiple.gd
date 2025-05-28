extends Control

@onready var pregunta_label = $MarginContainer/VBoxContainer/PreguntaLabel
@onready var opciones_container = $MarginContainer/VBoxContainer/OpcionesContainer
@onready var verificar_button = $MarginContainer/VBoxContainer/VerificarButton
@onready var continuar_button = $MarginContainer/VBoxContainer/ContinuarButton

var datos = []
var pregunta_actual = {}
var opcion_seleccionada = ""

func _ready():
	randomize()
	cargar_datos()
	conectar_senales()
	continuar_button.hide()

func conectar_senales():
	verificar_button.pressed.connect(verificar_respuesta)
	continuar_button.pressed.connect(siguiente_actividad)
	
	for opcion in opciones_container.get_children():
		opcion.pressed.connect(_on_opcion_pressed.bind(opcion))

func cargar_datos():
	var ruta = "res://datos/saludos.json"
	if FileAccess.file_exists(ruta):
		var file = FileAccess.open(ruta, FileAccess.READ)
		var json_text = file.get_as_text()
		var parsed = JSON.parse_string(json_text)
		if parsed:
			# Filtrar solo las preguntas
			datos = parsed.filter(func(item): return item.get("tipo") == "pregunta")
			print("✅ Preguntas cargadas: ", datos.size())
			cargar_pregunta()
		else:
			print("❌ Error al parsear JSON")
	else:
		print("❌ Archivo JSON no encontrado: ", ruta)

func cargar_pregunta():
	if datos.is_empty():
		pregunta_label.text = "No hay más preguntas disponibles"
		return
	
	# Reiniciar estado
	opcion_seleccionada = ""
	verificar_button.disabled = true
	verificar_button.show()
	continuar_button.hide()
	
	# Seleccionar pregunta aleatoria
	pregunta_actual = datos.pick_random()
	pregunta_label.text = pregunta_actual["pregunta"]
	
	# Asignar opciones a los botones
	var opciones = pregunta_actual["opciones"].duplicate()
	opciones.shuffle()  # Mezclar opciones
	
	for i in range(opciones_container.get_child_count()):
		var boton = opciones_container.get_child(i)
		if i < opciones.size():
			boton.text = opciones[i]
			boton.show()
			boton.disabled = false
			boton.modulate = Color.WHITE
		else:
			boton.hide()

func _on_opcion_pressed(opcion_button: Button):
	opcion_seleccionada = opcion_button.text
	verificar_button.disabled = false
	
	# Visual feedback
	for opcion in opciones_container.get_children():
		opcion.modulate = Color.WHITE
	opcion_button.modulate = Color(0.8, 0.8, 1.0)

func verificar_respuesta():
	if opcion_seleccionada == pregunta_actual["respuesta_correcta"]:
		# Respuesta correcta
		for opcion in opciones_container.get_children():
			if opcion.text == opcion_seleccionada:
				opcion.modulate = Color(0.2, 0.8, 0.2)  # Verde
			opcion.disabled = true
		
		verificar_button.hide()
		continuar_button.show()
		await get_tree().create_timer(1.0).timeout
		siguiente_actividad()
	else:
		# Respuesta incorrecta
		for opcion in opciones_container.get_children():
			if opcion.text == opcion_seleccionada:
				opcion.modulate = Color(0.8, 0.2, 0.2)  # Rojo
		
		await get_tree().create_timer(1.0).timeout
		
		# Resetear selección
		opcion_seleccionada = ""
		verificar_button.disabled = true
		for opcion in opciones_container.get_children():
			opcion.modulate = Color.WHITE

func siguiente_actividad():
	get_tree().change_scene_to_file("res://scenes/ACTIVIDADESM1/EscuchaReaciona.tscn") 
