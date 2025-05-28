extends Control

@onready var grid_container = $MarginContainer/VBoxContainer/GridContainer
@onready var continuar_button = $MarginContainer/VBoxContainer/ContinuarButton
@onready var instruccion_label = $MarginContainer/VBoxContainer/InstruccionLabel

var primera_seleccion = null
var segunda_seleccion = null
var puede_seleccionar = true
var datos = []
var pares_correctos = {}

func _ready():
	cargar_datos()
	continuar_button.disabled = true
	continuar_button.pressed.connect(siguiente_escena)
	continuar_button.text = "CONTINUAR"

func siguiente_escena():
	get_tree().change_scene_to_file("res://scenes/ACTIVIDADESM1/TraduccionDirecta.tscn")

func cargar_datos():
	var ruta = "res://datos/saludos.json"
	if FileAccess.file_exists(ruta):
		var file = FileAccess.open(ruta, FileAccess.READ)
		var json_text = file.get_as_text()
		var parsed = JSON.parse_string(json_text)
		if parsed:
			# Filtrar solo los elementos que tienen español y nahuatl, sin importar otros campos
			datos = parsed.filter(func(item): 
				return item.has("espanol") and item.has("nahuatl")
			)
			print("✅ Datos cargados: ", datos.size())
			cargar_actividad()
		else:
			print("❌ Error al parsear JSON")
	else:
		print("❌ Archivo JSON no encontrado: ", ruta)

func cargar_actividad():
	# Limpiar tarjetas existentes
	for child in grid_container.get_children():
		child.queue_free()
	
	# Reiniciar estado
	primera_seleccion = null
	segunda_seleccion = null
	puede_seleccionar = true
	pares_correctos.clear()
	continuar_button.disabled = true
	
	# Seleccionar pares aleatorios del JSON
	var pares_seleccionados = []
	var num_pares = min(4, datos.size())  # Usar 4 pares o menos si no hay suficientes datos
	
	# Mezclar datos para selección aleatoria
	var datos_mezclados = datos.duplicate()
	datos_mezclados.shuffle()
	
	# Seleccionar los primeros n pares
	for i in range(num_pares):
		if i < datos_mezclados.size():
			pares_seleccionados.append(datos_mezclados[i])
			pares_correctos[datos_mezclados[i]["espanol"]] = datos_mezclados[i]["nahuatl"]
	
	crear_tarjetas(pares_seleccionados)

func crear_tarjetas(pares):
	# Crear array con todas las palabras
	var todas_palabras = []
	for par in pares:
		todas_palabras.append(par["espanol"])
		todas_palabras.append(par["nahuatl"])
	
	# Mezclar las palabras
	todas_palabras.shuffle()
	
	# Crear botones para cada palabra
	for palabra in todas_palabras:
		var tarjeta = Button.new()
		tarjeta.text = palabra
		tarjeta.custom_minimum_size = Vector2(0, 80)
		tarjeta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tarjeta.add_theme_font_size_override("font_size", 24)
		tarjeta.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
		
		# Añadir el estilo de la tarjeta
		var estilo = StyleBoxFlat.new()
		estilo.bg_color = Color.WHITE
		estilo.corner_radius_top_left = 15
		estilo.corner_radius_top_right = 15
		estilo.corner_radius_bottom_right = 15
		estilo.corner_radius_bottom_left = 15
		estilo.shadow_color = Color(0, 0, 0, 0.1)
		estilo.shadow_size = 2
		estilo.shadow_offset = Vector2(0, 2)
		tarjeta.add_theme_stylebox_override("normal", estilo)
		
		# Conectar la señal pressed
		tarjeta.pressed.connect(_on_tarjeta_pressed.bind(tarjeta))
		grid_container.add_child(tarjeta)

func _on_tarjeta_pressed(tarjeta: Button):
	if not puede_seleccionar:
		return
		
	if primera_seleccion == null:
		primera_seleccion = tarjeta
		tarjeta.modulate = Color(0.8, 0.8, 1.0)  # Azul claro para indicar selección
	elif segunda_seleccion == null and tarjeta != primera_seleccion:
		segunda_seleccion = tarjeta
		tarjeta.modulate = Color(0.8, 0.8, 1.0)
		verificar_par()

func verificar_par():
	puede_seleccionar = false
	
	# Verificar si es un par correcto
	var es_correcto = false
	if pares_correctos.has(primera_seleccion.text) and pares_correctos[primera_seleccion.text] == segunda_seleccion.text:
		es_correcto = true
	elif pares_correctos.has(segunda_seleccion.text) and pares_correctos[segunda_seleccion.text] == primera_seleccion.text:
		es_correcto = true
	
	# Mostrar resultado
	if es_correcto:
		primera_seleccion.modulate = Color(0.8, 1.0, 0.8)  # Verde claro
		segunda_seleccion.modulate = Color(0.8, 1.0, 0.8)
		primera_seleccion.disabled = true
		segunda_seleccion.disabled = true
		verificar_victoria()
	else:
		# Esperar un momento y resetear
		await get_tree().create_timer(1.0).timeout
		primera_seleccion.modulate = Color.WHITE
		segunda_seleccion.modulate = Color.WHITE
	
	primera_seleccion = null
	segunda_seleccion = null
	puede_seleccionar = true

func verificar_victoria():
	# Verificar si todas las tarjetas están deshabilitadas
	var todas_correctas = true
	for tarjeta in grid_container.get_children():
		if not tarjeta.disabled:
			todas_correctas = false
			break
	
	if todas_correctas:
		# Habilitar el botón continuar cuando todas las parejas estén correctas
		continuar_button.disabled = false
