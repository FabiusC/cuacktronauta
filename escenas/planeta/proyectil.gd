extends RigidBody2D

func _ready():
	lock_rotation = true
	
func lanzar(direccion: Vector2, velocidad: float):
	lock_rotation = true
	reparent(get_parent().get_parent())
	apply_central_impulse(direccion * velocidad)
	var timer = Timer.new()
	add_child(timer)
	timer.start(5.0)
	timer.timeout.connect(queue_free)
