extends CharacterBody2D

var direccion: int  # Sin valor inicial para que no se bloquee
var speed: float = 800.0
var establecida: bool = false

func establecer_direccion(nueva_dir: int):
	direccion = nueva_dir
	establecida = true
	# Voltear el sprite de una vez
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.flip_h = (direccion == -1)

func _physics_process(delta: float):
	if not establecida: return # No se mueve hasta que el personaje le diga hacia donde
	
	# Usamos move_and_collide directamente con la dirección
	var movimiento = Vector2(speed * direccion, 0)
	var colision = move_and_collide(movimiento * delta)
	
	if colision:
		var objeto = colision.get_collider()
		if objeto.has_method("recibir_daño"):
			objeto.recibir_daño()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
