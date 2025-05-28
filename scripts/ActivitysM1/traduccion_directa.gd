extends Control

@onready var frase_espanol = $MarginContainer/VBoxContainer/FraseEspanol
@onready var traduccion_edit = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/TraduccionEdit
@onready var resultado_label = $MarginContainer/VBoxContainer/ResultadoLabel
@onready var verificar_button = $MarginContainer/VBoxContainer/VerificarButton
@onready var continuar_button = $MarginContainer/VBoxContainer/ContinuarButton

var datos = []
var frase_actual = {}

func _ready():
	cargar_datos()
	verificar_button.pressed.connect(verificar_traduccion)
	continuar_button.pressed.connect(siguiente_escena)
	traduccion_edit.text_submitted.connect(verificar_traduccion)

func cargar_datos():
	var ruta = "res://datos/saludos.json"
	if FileAccess.file_exists(ruta):
		var file = FileAccess.open(ruta, FileAccess.READ)
		var json_text = file.get_as_text()
		var parsed = JSON.parse_string(json_text)
		if parsed:
			datos = parsed
			print("✅ Datos cargados: ", datos.size())
			cargar_frase()
		else:
			print("❌ Error al parsear JSON")
	else:
		print("❌ Archivo JSON no encontrado: ", ruta)

func cargar_frase():
	if datos.is_empty():
		resultado_label.text = "❌ No se encontraron datos"
		return
	
	# Reiniciar estado
	traduccion_edit.text = ""
	resultado_label.text = ""
	continuar_button.hide()
	verificar_button.show()
	
	# Seleccionar frase aleatoria
	frase_actual = datos.pick_random()
	frase_espanol.text = frase_actual["espanol"]

func verificar_traduccion(texto_submitted = null):
	var traduccion = traduccion_edit.text.strip_edges()
	if traduccion.is_empty():
		resultado_label.text = "Por favor, escribe una traducción"
		return
	
	if traduccion.to_lower() == frase_actual["nahuatl"].to_lower():
		resultado_label.text = "✅ ¡Correcto!"
		resultado_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
		verificar_button.hide()
		continuar_button.show()
	else:
		resultado_label.text = "❌ Incorrecto. Intenta de nuevo."
		resultado_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
		traduccion_edit.grab_focus()

func siguiente_escena():
	get_tree().change_scene_to_file("res://scenes/ACTIVIDADESM1/CompletarOracion.tscn") 
