extends Node2D

@export var enemigo_escena: PackedScene 
@export var cantidad_a_generar: int = 5
@export var modal_panel: Panel
@export var texto_label: Label

@onready var boton_restart = modal_panel.get_node("BotonReiniciar") 

var enemigos_vivos: int = 0
var victoria_activada: bool = false
var derrota_activada: bool = false
var en_introduccion: bool = true

func _ready():
	# 1. Al inicio, mostramos el modal con la INTRODUCCIÓN (Punto 2.3)
	if modal_panel != null:
		mostrar_introduccion()
	
	# El juego se queda "esperando" a que el jugador cierre la intro
	# No generamos enemigos todavía

func mostrar_introduccion():
	en_introduccion = true
	# Aquí va el texto que los encargados de Narrativa redactaron
	texto_label.text = "INTRODUCCIÓN:\nHan detectado un virus en el sistema digestivo.\n MISION: Eliminarlos y mantener la salud!\n\n"
	
	modal_panel.visible = true
	boton_restart.visible = true
	# Cambiamos temporalmente el texto del botón para que diga "EMPEZAR"
	boton_restart.text = "EMPEZAR"

func generar_horda_centrada():
	if enemigo_escena == null:
		return
		
	var centro = get_viewport_rect().size / 2
	for i in range(cantidad_a_generar):
		var nuevo_enemigo = enemigo_escena.instantiate()
		var offset = Vector2(randf_range(-150, 150), randf_range(-150, 150))
		nuevo_enemigo.position = centro + offset
		add_child(nuevo_enemigo)

func enemigo_eliminado():
	if derrota_activada: return 
	
	enemigos_vivos -= 1
	
	if enemigos_vivos > 0:
		lanzar_consejo_rapido()
	else:
		mostrar_victoria_final()

func lanzar_consejo_rapido():
	if derrota_activada or victoria_activada or en_introduccion: return
	
	var consejos = [
		"¡Bien! Lavarse las manos evita infecciones.",
		"¡Sigue así! Beber agua purificada es vital.",
		"¡Buen impacto! La higiene previene bacterias.",
		"¡Excelente! Lava siempre tus frutas y verduras."
	]
	
	texto_label.text = consejos[randi() % consejos.size()]
	modal_panel.visible = true
	
	await get_tree().create_timer(1.5).timeout
	
	if not derrota_activada and not victoria_activada and enemigos_vivos > 0:
		modal_panel.visible = false

func mostrar_victoria_final():
	victoria_activada = true
	# CONCLUSIÓN NARRATIVA (Punto 2.3)
	texto_label.text = "¡Victoria Total!\nHas limpiado el sistema digestivo con éxito."
	
	modal_panel.visible = true
	boton_restart.visible = true
	boton_restart.text = "REINICIAR"

func mostrar_derrota():
	if victoria_activada: return
	derrota_activada = true
	texto_label.text = "¡OH NO!\nTe estás muriendo...\nLa infección fue muy fuerte."
	modal_panel.visible = true
	if boton_restart != null:
		boton_restart.visible = true
		boton_restart.text = "REINTENTAR"

func _on_boton_reiniciar_pressed():
	# Si estábamos en la intro, esto inicia el juego real
	if en_introduccion:
		en_introduccion = false
		modal_panel.visible = false
		boton_restart.visible = false
		
		# Preparamos el juego y soltamos los virus
		enemigos_vivos = cantidad_a_generar
		generar_horda_centrada()
	else:
		# Si ya estábamos jugando, reinicia la escena
		get_tree().reload_current_scene()
