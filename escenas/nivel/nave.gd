extends Area2D

@onready var animated_sprite = $Explosion
@onready var collision_shape = $CollisionPolygon2D

var velocidad: float = 5.0
var direccion: Vector2 = Vector2.ZERO
var objetivo: Area2D = null
var velocidad_base: float = 0.0
@onready var nivel_principal = get_tree().root.get_node("Nivel1")

func _ready():
	if velocidad == 0.0:
		print("ALERTA: Nave creada pero no inicializada (Velocidad 0)")
	add_to_group("naves_enemigas")
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	var notifier = get_node_or_null("VisibleOnScreenNotifier2D")
	if notifier:
		notifier.screen_exited.connect(queue_free)
	else:
		var auto_notifier = VisibleOnScreenNotifier2D.new()
		add_child(auto_notifier)
		auto_notifier.screen_exited.connect(queue_free)

func inicializar(pos_inicio: Vector2, planeta_objetivo: Node2D, velocidad_nueva: float):
	global_position = pos_inicio
	objetivo = planeta_objetivo
	velocidad_base = velocidad_nueva
	velocidad = velocidad_base
	if objetivo:
		direccion = (objetivo.global_position - global_position).normalized()
		rotation = direccion.angle() + ((2*PI)/4)
	else:
		print("ERROR: Nave creada sin objetivo válido")

func cambiar_velocidad_transicion(en_pausa: bool):
	if en_pausa:
		velocidad = velocidad_base / 3.0
	else:
		velocidad = velocidad_base

func _process(delta: float):
	position += direccion * velocidad * delta

func destroy():
	var nivel = get_tree().current_scene
	velocidad = velocidad/2
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	if nivel and nivel.has_method("sumar_puntos"):
		nivel_principal.sumar_puntos(10)
	else:
		var nivel_root = get_tree().root.get_node_or_null("Nivel1")
		if nivel_root and nivel_root.has_method("sumar_puntos"):
			nivel_root.sumar_puntos(10)
	if animated_sprite:
		animated_sprite.play("default")
		await animated_sprite.animation_finished
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("cuerpos_celestes") and area.name != "Sol":
		impactar_planeta(area)

func impactar_planeta(planeta):
	if planeta.has_method("recibir_dano"):
		planeta.recibir_dano(1)
	queue_free()
