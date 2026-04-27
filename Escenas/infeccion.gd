extends CharacterBody2D

@export var velocidad = 400.0
@export var salud: int = 3
var direccion = Vector2.ZERO
var esta_muerto: bool = false 

@onready var sprite = $AnimatedSprite2D

func _ready():
	direccion = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	sprite.play("Idle") 
	actualizar_sprite()

func _physics_process(_delta):
	if esta_muerto:
		velocity = velocity.move_toward(Vector2.ZERO, 10)
		move_and_slide()
		return 

	velocity = direccion * velocidad
	
	# move_and_slide() devuelve True si hubo colisiones
	move_and_slide()

	# --- NUEVA LÓGICA: Daño al jugador ---
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var objeto = colision.get_collider()
		
		# Si el objeto con el que chocamos es el jugador (Character)
		if objeto.has_method("recibir_daño_jugador"):
			objeto.recibir_daño_jugador()
	# -------------------------------------

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
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(10, 10, 10), 0.05)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.05)
	
	if salud <= 0:
		morir()

func morir():
	if esta_muerto: return
	esta_muerto = true
	
	collision_layer = 0 
	collision_mask = 0
	
	if get_parent().has_method("enemigo_eliminado"):
		get_parent().enemigo_eliminado()
	
	if sprite.sprite_frames.has_animation("dead"):
		sprite.play("dead")
		if not sprite.animation_finished.is_connected(_al_terminar_animacion):
			sprite.animation_finished.connect(_al_terminar_animacion)
	else:
		queue_free()

func _al_terminar_animacion():
	if sprite.animation == "dead":
		queue_free()
