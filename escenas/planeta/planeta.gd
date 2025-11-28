extends Area2D

@export var masa: float = 1.0
@export var radio_orbita: float = 100.0
@export var velocidad_orbital: float = 1.0

@export var factor_base_disparo: float = 1000000.0 #Mayor = Mayor velocidad de la bala
@export var cooldown_max: float = 0.5
@export var factor_base_cooldown: float = 200.0 #Mayor = Menor cooldown

signal salud_cambiada(nueva_vida)

var sol: Area2D = null
var angulo_actual: float = 0.0 
var sprite_node: AnimatedSprite2D = null

# Disparos
var velocidad_disparo: float = 0.0
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var sonido_disparo: AudioStreamPlayer2D = $SonidoDisparo
@onready var sonido_muerte: AudioStreamPlayer2D = $SonidoMuerte
@onready var sonido_curacion: AudioStreamPlayer2D = $SonidoCuracion
@onready var sonido_seleccion: AudioStreamPlayer2D = $SonidoSeleccion
# Colores y Escenas
const COLOR_DESATURADO: Color = Color(0.5, 0.5, 0.5, 1.0)
const COLOR_NORMAL: Color = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_MUERTO: Color = Color(0.0, 0.0, 0.0, 1.0)
const PROYECTIL_SCENE = preload("res://escenas/planeta/proyectil.tscn")

#Estado
var is_selected: bool = false
var contenedor_balas: Node2D = null
var health: int = 4
var is_dead: bool = false
var en_zona_activa: bool = true

func _ready():
	angulo_actual = 0.0
	add_to_group("cuerpos_celestes")
	if has_node("AnimatedSprite2D"):
		sprite_node = $AnimatedSprite2D
	pass

func inicializar_datos():
	var radio_valido = maxf(radio_orbita, 10.0)
	velocidad_disparo = factor_base_disparo / radio_valido
	velocidad_disparo = clampf(velocidad_disparo, 100.0, 1500.0)
	var tiempo_cooldown = factor_base_cooldown / radio_valido
	tiempo_cooldown = clampf(tiempo_cooldown, 0.1, 1.0)
	print(name, " | Radio:", radio_orbita, " -> Vel Bala:", velocidad_disparo, 0.1, " -> CD:", tiempo_cooldown, 0.01)
	if is_instance_valid(cooldown_timer):
		cooldown_timer.wait_time = tiempo_cooldown
		cooldown_timer.one_shot = true
		if not cooldown_timer.is_connected("timeout", Callable(self, "_on_cooldown_timer_timeout")):
			cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	else: 
		print("ERROR: El nodo Timer 'CooldownTimer' no fue encontrado en la escena.")

# SALUD PLANETA
func recibir_dano(cantidad: int):
	if is_dead: 
		return 
	emit_signal("salud_cambiada", health)
	health -= cantidad
	
	if health <= 0:
		morir()

func morir():
	is_dead = true
	health = 0
	if sprite_node:
		sprite_node.modulate = COLOR_MUERTO
	if sonido_muerte:
		sonido_muerte.play()

func restaurar_salud():
	if not is_dead:
		health = 5
		emit_signal("salud_cambiada", health)
		health = 4
		set_saturacion(false)
		if sonido_curacion:
			sonido_curacion.play()

# Color Planetas
func set_saturacion(saturado: bool):
	if is_dead: return
	if sprite_node:
		if saturado:
			sprite_node.modulate = COLOR_NORMAL
		else:
			sprite_node.modulate = COLOR_DESATURADO

#Movimiento Traslacion
func _process(delta: float):
	if sol != null:
		angulo_actual += velocidad_orbital * delta
		var nueva_x = radio_orbita * cos(angulo_actual)
		var nueva_y = radio_orbita * sin(angulo_actual)
		
		global_position = sol.global_position + Vector2(nueva_x, nueva_y)
		look_at(global_position + Vector2(-nueva_y, nueva_x))
		var limite_horizonte = 50.0 
		
		if global_position.y > limite_horizonte:
			en_zona_activa = false
			if sprite_node and not is_dead:
				sprite_node.modulate = Color(0.3, 0.3, 0.3, 1.0)
		else:
			en_zona_activa = true
			if sprite_node and not is_dead and not is_selected:
				sprite_node.modulate = COLOR_DESATURADO
			elif sprite_node and is_selected:
				sprite_node.modulate = COLOR_NORMAL

func disparar(direccion_al_cursor: Vector2):
	
	if name == "Jupiter" or is_dead or not en_zona_activa:return
	
	#Verificar Cooldown
	if cooldown_timer and cooldown_timer.is_stopped():
		var proyectil = PROYECTIL_SCENE.instantiate()
		if get_parent() and get_parent().get_parent():
			get_parent().get_parent().add_child(proyectil)
		else:
			get_parent().add_child(proyectil)
		proyectil.global_position = global_position
		if proyectil.has_method("lanzar"):
			proyectil.lanzar(direccion_al_cursor.normalized(), velocidad_disparo, self)
		cooldown_timer.start()
		reproducir_sonido_disparo()

func reproducir_sonido_disparo():
	if sonido_disparo and sonido_disparo.stream:
		sonido_disparo.pitch_scale = randf_range(0.9, 1.1)
		sonido_disparo.play()

func _on_cooldown_timer_timeout():
	pass

func set_selected(selected: bool):
	if not en_zona_activa: 
		is_selected = false
		return
	is_selected = selected
	if sprite_node:
		if is_selected:
			if sonido_seleccion: sonido_seleccion.play()
			sprite_node.modulate = COLOR_NORMAL
		else:
			sprite_node.modulate = COLOR_DESATURADO
