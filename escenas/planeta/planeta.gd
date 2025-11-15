extends Node2D

@export var masa: float = 1.0 
@export var radio_orbita: float = 100.0
@export var velocidad_orbital: float = 1.0
@export var factor_base_disparo: float = 500.0
@export var factor_base_cooldown: float = 10.0

var sol: Node2D = null
var angulo_actual: float = 0.0 
var sprite_node: AnimatedSprite2D = null
#Disparos
var velocidad_disparo: float = 0.0
var cooldown_timer: Timer
#Colores
const COLOR_DESATURADO: Color = Color(0.5, 0.5, 0.5, 1.0)
const COLOR_NORMAL: Color = Color(1.0, 1.0, 1.0, 1.0)
const PROYECTIL_SCENE = preload("res://escenas/planeta/proyectil.tscn")

func _ready():
	angulo_actual = 0.0
	if has_node("AnimatedSprite2D"):
		sprite_node = $AnimatedSprite2D
	var masa_valida = maxf(masa, 0.01)
	velocidad_disparo = factor_base_disparo / masa_valida
	
	var radio_valido = maxf(radio_orbita, 1.0)
	var tiempo_cooldown = factor_base_cooldown / (radio_valido / 100.0)
	
	cooldown_timer = Timer.new()
	add_child(cooldown_timer)
	cooldown_timer.one_shot = true 
	cooldown_timer.wait_time = tiempo_cooldown
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	cooldown_timer.start() 
	print("Planeta ", name, " | Cooldown: ", tiempo_cooldown, "s")
	
func set_saturacion(saturado: bool):
	if sprite_node:
		if saturado:
			sprite_node.modulate = COLOR_NORMAL
		else:
			sprite_node.modulate = COLOR_DESATURADO
		
func _process(delta: float):
	if sol != null:
		angulo_actual += velocidad_orbital * delta
		var nueva_x = radio_orbita * cos(angulo_actual)
		var nueva_y = radio_orbita * sin(angulo_actual)
		
		global_position = sol.global_position + Vector2(nueva_x, nueva_y)
		look_at(global_position + Vector2(-nueva_y, nueva_x))
	
func disparar(direccion_al_cursor: Vector2):
	if cooldown_timer and cooldown_timer.is_stopped():
		var proyectil = PROYECTIL_SCENE.instantiate()
		
		add_child(proyectil)
		
		proyectil.position = Vector2.ZERO 
		
		proyectil.lanzar(direccion_al_cursor.normalized(), velocidad_disparo)
		cooldown_timer.start()

func _on_cooldown_timer_timeout():
	pass
