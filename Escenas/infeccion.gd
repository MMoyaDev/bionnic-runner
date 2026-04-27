extends CharacterBody2D

@export var velocidad = 400.0
@export var salud: int = 3
var direccion = Vector2.ZERO
var esta_muerto: bool = false 

@onready var sprite = $AnimatedSprite2D

func _ready():
	# Dirección aleatoria para que no todos se muevan igual
	direccion = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	sprite.play("Idle") 
	actualizar_sprite()

func _physics_process(_delta):
	if esta_muerto:
		# Si está muerto, aplicamos una pequeña fricción para que no se detenga en seco
		velocity = velocity.move_toward(Vector2.ZERO, 10)
		move_and_slide()
		return 

	velocity = direccion * velocidad
	move_and_slide()

	# Rebotar en las paredes del intestino
	if is_on_wall() or is_on_floor() or is_on_ceiling():
		var colision = get_last_slide_collision()
		if colision:
			var normal = colision.get_normal()
			direccion = direccion.bounce(normal)
			actualizar_sprite()

func actualizar_sprite():
	if direccion.x != 0:
		sprite.flip_h = (direccion.x < 0)

func recibir_daño():
	if esta_muerto:
		return

	salud -= 1
	
	# Efecto visual de flash blanco al recibir impacto
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(10, 10, 10), 0.05)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.05)
	
	if salud <= 0:
		morir()

func morir():
	esta_muerto = true
	
	# 1. Desactivamos colisiones para que no estorbe muerto
	collision_layer = 0 
	collision_mask = 0
	
	# 2. Avisamos al contador del nivel (Node2D)
	if get_parent().has_method("enemigo_eliminado"):
		get_parent().enemigo_eliminado()
	
	# 3. Lanzamos la animación de muerte
	if sprite.sprite_frames.has_animation("dead"):
		sprite.play("dead")
		# Conectamos la señal para borrarlo al terminar la animación
		if not sprite.animation_finished.is_connected(_al_terminar_animacion):
			sprite.animation_finished.connect(_al_terminar_animacion)
	else:
		# Si no hay animación, lo borramos de inmediato
		queue_free()

func _al_terminar_animacion():
	# Solo lo borramos si la animación que terminó es la de muerte
	if sprite.animation == "dead":
		queue_free()
