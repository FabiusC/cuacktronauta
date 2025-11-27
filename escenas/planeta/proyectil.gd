extends Area2D

var planeta_origen: Area2D = null
var velocidad_actual: float = 0.0
var direccion_movimiento: Vector2 = Vector2.ZERO

func _ready():
	var notifier = get_node_or_null("VisibleOnScreenNotifier2D")
	if notifier:
		notifier.screen_exited.connect(queue_free)
	var timer = Timer.new()
	add_child(timer)
	timer.start(10.0)
	timer.timeout.connect(queue_free)
	
	if not area_entered.is_connected(_on_impacto):
		area_entered.connect(_on_impacto)
		
	if not body_entered.is_connected(_on_impacto):
		body_entered.connect(_on_impacto)
	
func lanzar(direccion: Vector2, velocidad: float, origen: Area2D):
	if get_parent() and get_parent().get_parent():
		reparent(get_parent().get_parent())
	planeta_origen = origen
	direccion_movimiento = direccion.normalized()
	velocidad_actual = velocidad
	rotation = direccion_movimiento.angle()

func _process(delta: float):
	position += direccion_movimiento * velocidad_actual * delta

func _on_impacto(objeto_tocado):
	if objeto_tocado == planeta_origen:
		return
	print("Bala chocó con: ", objeto_tocado.name, " | Grupos: ", objeto_tocado.get_groups())
	if objeto_tocado.is_in_group("cuerpos_celestes"):
		queue_free()
	elif objeto_tocado.is_in_group("naves_enemigas"):
		if objeto_tocado.has_method("destroy"):
			objeto_tocado.destroy()
			queue_free()
