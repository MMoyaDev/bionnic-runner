extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export var velocidad = 400
@export var salto = -500 
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")

# Carga de la bala
var bullet_scene = preload("res://Escenas/bullet.tscn")

# --- REFERENCIAS ---
@onready var sprite = $AnimatedSprite2D 
@onready var spawn_point = $AnimatedSprite2D/SpawnPoint

# --- ESTADOS ---
var can_shoot = true
var ultima_direccion = 1 # 1 = Derecha, -1 = Izquierda

func _ready():
	# Seguridad: Si el spawn está en el centro, lo alejamos 35 píxeles
	if spawn_point.position.x == 0:
		spawn_point.position.x = 35

func _physics_process(delta):
	# 1. Gravedad
	if not is_on_floor():
		velocity.y += gravedad * delta

	# 2. Saltar (Usando tu acción personalizada)
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = salto

	# 3. Movimiento Lateral (Usando mover_izq y mover_der)
	var input_dir = Input.get_axis("mover_izq", "mover_der")
	
	if input_dir != 0:
		velocity.x = input_dir * velocidad
		sprite.flip_h = (input_dir < 0)
		
		# ACTUALIZACIÓN DE DIRECCIÓN
		ultima_direccion = sign(input_dir)
		
		# MOVER EL PUNTO DE DISPARO AL FRENTE
		spawn_point.position.x = abs(spawn_point.position.x) * ultima_direccion
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)

	# 4. Lógica de Disparo (Usando tu acción "disparar")
	# Esto permite que funcione con CTRL y con el botón táctil del APK
	if Input.is_action_pressed("disparar"):
		if can_shoot:
			disparar()
			can_shoot = false 
	else:
		can_shoot = true 

	actualizar_animaciones(input_dir)
	move_and_slide()

func disparar():
	# Instanciar la bala
	var bala = bullet_scene.instantiate()
	
	# Colocarla en la posición global del SpawnPoint
	bala.global_position = spawn_point.global_position
	
	# AGREGAR AL MUNDO PRIMERO
	get_tree().root.add_child(bala)
	
	# ENVIAR LA DIRECCIÓN A LA BALA
	if bala.has_method("establecer_direccion"):
		bala.establecer_direccion(ultima_direccion)
	elif "direccion" in bala:
		bala.direccion = ultima_direccion
		
	print("Bala enviada con dirección: ", ultima_direccion)

func actualizar_animaciones(input_dir):
	if not is_on_floor():
		sprite.play("Jump")
	elif input_dir != 0:
		sprite.play("Run")
	else:
		sprite.play("Idle")
