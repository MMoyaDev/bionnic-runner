extends Node2D

@export var enemigo_escena: PackedScene 
@export var cantidad_a_generar: int = 5
@export var modal_panel: Panel
@export var texto_label: Label

# Buscamos el botón exactamente como se llama en tu imagen
@onready var boton_restart = modal_panel.get_node("BotonReiniciar") 

var enemigos_vivos: int = 0
var victoria_activada: bool = false

func _ready():
	# 1. Ocultamos el panel y el botón al iniciar
	if modal_panel != null:
		modal_panel.visible = false
		boton_restart.visible = false
	
	# 2. Preparamos el contador
	enemigos_vivos = cantidad_a_generar
	
	# 3. Esperamos un poco y generamos la horda
	await get_tree().create_timer(0.3).timeout
	generar_horda_centrada()

func generar_horda_centrada():
	if enemigo_escena == null:
		print("--- ERROR: Falta la escena del virus en el Inspector ---")
		return
		
	var centro = get_viewport_rect().size / 2
	for i in range(cantidad_a_generar):
		var nuevo_enemigo = enemigo_escena.instantiate()
		var offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
		nuevo_enemigo.position = centro + offset
		add_child(nuevo_enemigo)

# Esta función es la que llama tu script de virus al morir
func enemigo_eliminado():
	enemigos_vivos -= 1
	
	if enemigos_vivos > 0:
		lanzar_consejo_rapido()
	else:
		mostrar_victoria_final()

func lanzar_consejo_rapido():
	var consejos = [
		"¡Bien! Lavarse las manos evita infecciones.",
		"¡Sigue así! Beber agua purificada es vital.",
		"¡Buen impacto! La higiene previene bacterias.",
		"¡Excelente! Lava siempre tus frutas y verduras."
	]
	
	texto_label.text = consejos[randi() % consejos.size()]
	modal_panel.visible = true
	
	# Desaparece el consejo después de 1.5 segundos para seguir jugando
	await get_tree().create_timer(1.5).timeout
	
	# Solo lo oculta si no hemos ganado ya
	if enemigos_vivos > 0:
		modal_panel.visible = false

func mostrar_victoria_final():
	victoria_activada = true
	texto_label.text = "¡VICTORIA TOTAL!\nHas limpiado el sistema digestivo."
	modal_panel.visible = true
	
	# Aparece el botón de reinicio
	if boton_restart != null:
		boton_restart.visible = true

# RECUERDA: Conecta la señal 'pressed' de tu BotonReiniciar aquí
func _on_boton_reiniciar_pressed():
	get_tree().reload_current_scene()
