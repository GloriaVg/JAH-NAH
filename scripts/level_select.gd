extends Control

@onready var btns = [
	$VBoxContainer/ButtonLevel1,
	$VBoxContainer/ButtonLevel2,
	$VBoxContainer/ButtonLevel3,
	$VBoxContainer/ButtonLevel4,
	$VBoxContainer/ButtonLevel5
]

@onready var btn_back = $ButtonBack

func _ready():
	# Simulamos progreso, por ahora desbloqueamos solo el Nivel 1 y 2
	var nivel_desbloqueado = 2
	
	for i in btns.size():
		var button = btns[i]
		button.disabled = i >= nivel_desbloqueado
		button.text = "Nivel %d%s" % [i + 1, " 🔒" if button.disabled else ""]
		button.pressed.connect(func(): _on_level_pressed(i + 1))

	btn_back.pressed.connect(_on_back_pressed)

func _on_level_pressed(nivel):
	print("Entrar al Nivel ", nivel)
	# Aquí puedes cargar la escena del nivel correspondiente
	get_tree().change_scene_to_file("res://scenes/levels/level%d.tscn" % nivel)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
