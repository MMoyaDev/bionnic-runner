extends Control

# 1. Ruta corregida (Asegúrate que el nombre del archivo sea exacto)
@export var escena_juego = "res://Escenas/nivel_1.tscn"

@onready var panel_info = $Panel
@onready var texto_info = $Panel/Label

func _ready():
	# Ocultamos el panel al iniciar
	if panel_info:
		panel_info.visible = false

# --- BOTONES PRINCIPALES ---

func _on_boton_jugar_pressed():
	# Si tu nivel está en una carpeta, la ruta debe incluirla, ej: "res://Escenas/nivel_1.tscn"
	print("Cambiando a escena: ", escena_juego)
	get_tree().change_scene_to_file(escena_juego)

func _on_boton_consejos_pressed():
	if panel_info and texto_info:
		texto_info.text = "CONSEJOS SALUDABLES:\n\n1. Lava tus manos.\n2. Desinfecta comida.\n3. Bebe agua limpia."
		panel_info.visible = true

func _on_boton_asistencia_pressed():
	if panel_info and texto_info:
		texto_info.text = "LÍNEA DE SALUD:\n\nMarca al 911 en emergencias o consulta a tu médico."
		panel_info.visible = true

# --- BOTÓN DE CERRAR ---

func _on_boton_cerrar_inf_pressed():
	if panel_info:
		panel_info.visible = false
