extends CharacterBody2D

var velocidad = 400
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $AnimatedSprite2D 

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta

	var direccion = Input.get_axis("ui_left", "ui_right")
	
	if direccion != 0:
		velocity.x = direccion * velocidad
		sprite.play("Run")
		sprite.flip_h = (direccion < 0) 
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)
		sprite.play("Idle")

	move_and_slide()
