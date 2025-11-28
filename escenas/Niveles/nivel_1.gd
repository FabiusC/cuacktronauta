extends Node2D

const MENU_PAUSA_SCENE = preload("res://escenas/ui/menu_pausa.tscn")
const NAVE_SCENE = preload("res://escenas/nivel/Nave.tscn")
const PANTALLA_PERDISTE_SCENE = preload("res://escenas/ui/pantalla_perdiste.tscn") # Ajusta la ruta

@onready var sistema_solar = $SistemaSolar
@onready var spawn_timer = $SpawnTimer
@onready var round_timer = $RoundTimer
@onready var label_puntuacion = $HUD/LabelPuntuacion
@onready var label_anuncio_nivel = $HUD/LabelAnuncioNivel 
@onready var marker_spawn = $MarkerSpawn
@export var ronda_actual: int = 1
@export var factor_vel_nave: float = 8000.0

var timer_ronda_ref: Timer
var puntuacion: int = 0
var juego_terminado: bool = false

func _ready():
	randomize()
	if spawn_timer:
		spawn_timer.wait_time = 1.0 
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		spawn_timer.start()
	if label_anuncio_nivel:
		label_anuncio_nivel.visible = false
		
	configurar_timer_ronda()

func _process(delta):
	if juego_terminado: 
		return
	verificar_condicion_derrota()

#Logica Juego
func verificar_condicion_derrota():
	if not sistema_solar: return
	
	var planetas_vivos = 0
	for nodo in sistema_solar.get_children():
		if nodo is Area2D and nodo.name != "Jupiter" and nodo.name != "Sol":
			if "is_dead" in nodo:
				if nodo.is_dead == false:
					planetas_vivos += 1
	if planetas_vivos == 0:
		game_over()

func game_over():
	juego_terminado = true
	Global.puntos_actuales = puntuacion
	var pantalla = PANTALLA_PERDISTE_SCENE.instantiate()
	add_child(pantalla)

func sumar_puntos(cantidad: int):
	puntuacion += cantidad
	actualizar_interfaz_puntos()

func actualizar_interfaz_puntos():
	if label_puntuacion:
		label_puntuacion.text = "Score: %d" % puntuacion
	else:
		print("Advertencia: LabelPuntuacion no encontrado")

# LOGICA RONDAS
func configurar_timer_ronda():
	if round_timer:
		timer_ronda_ref = round_timer
	else:
		timer_ronda_ref = Timer.new()
		add_child(timer_ronda_ref)
	timer_ronda_ref.wait_time = 55.0 
	timer_ronda_ref.one_shot = true
	if not timer_ronda_ref.timeout.is_connected(_on_pre_ronda_terminada):
		timer_ronda_ref.timeout.connect(_on_pre_ronda_terminada)
	timer_ronda_ref.start()

func _on_pre_ronda_terminada():
	print("Fase final de ronda (5 segundos sin spawn)")
	spawn_timer.stop()
	get_tree().create_timer(5.0).timeout.connect(_on_ronda_terminada)

func _on_ronda_terminada():
	print("¡Fin de la Ronda ", ronda_actual, "!")
	sumar_puntos(100)
	spawn_timer.stop()
	if label_anuncio_nivel:
		label_anuncio_nivel.text = "NIVEL " + str(ronda_actual + 1)
		label_anuncio_nivel.visible = true
	curar_planetas()
	get_tree().call_group("naves_enemigas", "cambiar_velocidad_transicion", true) #Desacelerar Naves
	get_tree().create_timer(3.0).timeout.connect(iniciar_siguiente_ronda)

func iniciar_siguiente_ronda():
	ronda_actual += 1
	if label_anuncio_nivel:
		label_anuncio_nivel.visible = false
	
	print("Iniciando Ronda ", ronda_actual)
	
	get_tree().call_group("naves_enemigas", "cambiar_velocidad_transicion", false) #Acelerar Naves
	spawn_timer.start()
	timer_ronda_ref.start() 

func curar_planetas():
	if not sistema_solar: return
	for planeta in sistema_solar.get_children():
		if is_instance_valid(planeta) and planeta.has_method("restaurar_salud"):
			planeta.restaurar_salud()

# SPAWN DE NAVES
func _on_spawn_timer_timeout():
	var factor_n: int = ronda_actual
	var cantidad_lote_l: int = randi_range(0, factor_n)
	if cantidad_lote_l > 0:
		spawn_lote(cantidad_lote_l)

func spawn_lote(cantidad: int):
	for i in range(cantidad):
		var delay = randf_range(0.0, 0.1)
		get_tree().create_timer(delay).timeout.connect(generar_nave)

func generar_nave():
	if not sistema_solar: return
	#Seleccion de objetivo
	var objetivos_validos = []
	var nodo_sol = null
	for nodo in sistema_solar.get_children():
		if nodo is Area2D and nodo.name != "Jupiter":
			var esta_vivo = true
			if "is_dead" in nodo and nodo.is_dead:
				esta_vivo = false
			var esta_activo = true
			if "en_zona_activa" in nodo and not nodo.en_zona_activa:
				esta_activo = false
			if esta_vivo and esta_activo:
				objetivos_validos.append(nodo)
	var objetivo_seleccionado = null
	if not objetivos_validos.is_empty():
		objetivo_seleccionado = objetivos_validos.pick_random()
	elif nodo_sol:
		objetivo_seleccionado = nodo_sol
	else:
		return
	var spawn_y = -350
	var min_x = -500
	var max_x = 500
	
	if marker_spawn:
		spawn_y = marker_spawn.global_position.y
		var pantalla_size = get_viewport_rect().size
		min_x = -(pantalla_size.x)
		max_x = (pantalla_size.x)
	
	var spawn_x = randf_range(min_x, max_x)
	var posicion_inicio = Vector2(spawn_x, spawn_y)
	var nave = NAVE_SCENE.instantiate()
	add_child(nave)
	var multiplicador_ronda = float(ronda_actual) / 10.0
	var velocidad_base = factor_vel_nave * multiplicador_ronda
	var variacion = velocidad_base * 0.1
	var velocidad_final = randf_range(velocidad_base - variacion, velocidad_base + variacion)
	velocidad_final = clampf(velocidad_final, 50.0, 3000.0)
	if nave.has_method("inicializar"):
		nave.inicializar(posicion_inicio, objetivo_seleccionado, velocidad_final)

func _on_pausa_pressed():
	if get_node_or_null("MenuPausa"):
		return
	var menu_pausa_instance = MENU_PAUSA_SCENE.instantiate()
	add_child(menu_pausa_instance)

func _on_zona_muerte_area_entered(area):
	if area.is_in_group("nave"):
		area.queue_free()
