extends Node2D

const SOL_SCENE = preload("res://escenas/planeta/sol.tscn")
const PLANETA_SCENE = preload("res://escenas/planeta/planeta.tscn")

const SOL_DATOS = {
	"masa": 250.0,
	"sprite_frames_path": "res://sprite_frames/sol.tres",
	"scale_factor": 1.5
}

const DATOS_PLANETAS = [
	{ "nombre": "Mercurio", "radio": 250.0, "masa": 0.1, "sprite_frames_path": "res://sprite_frames/mercurio.tres", "scale_factor": 0.3 },
	{ "nombre": "Venus","radio": 400.0, "masa": 0.3, "sprite_frames_path": "res://sprite_frames/venus.tres", "scale_factor": 0.5 },
	{ "nombre": "Tierra","radio": 550.0, "masa": 0.5, "sprite_frames_path": "res://sprite_frames/tierra.tres", "scale_factor": 0.55 },
	{ "nombre": "Marte","radio": 700.0, "masa": 0.2, "sprite_frames_path": "res://sprite_frames/marte.tres", "scale_factor": 0.4 },
	{ "nombre": "Jupiter","radio": 1000.0, "masa": 2.5, "sprite_frames_path": "res://sprite_frames/jupiter.tres", "scale_factor": 1.0 },
	{ "nombre": "Saturno","radio": 1400.0, "masa": 1.8, "sprite_frames_path": "res://sprite_frames/saturno.tres", "scale_factor": 0.8 },
	{ "nombre": "Urano","radio": 1850.0, "masa": 1.2, "sprite_frames_path": "res://sprite_frames/urano.tres", "scale_factor": 0.7 },
	{ "nombre": "Neptuno","radio": 2300.0, "masa": 1.1, "sprite_frames_path": "res://sprite_frames/neptuno.tres", "scale_factor": 0.5 }
]

const VELOCIDADES_ORBITALES = {
	"Mercurio": 1.8,
	"Venus": 1.2,
	"Tierra": 1.0,
	"Marte": 0.9,
	"Jupiter": 0.5,
	"Saturno": 0.35,
	"Urano": 0.25,
	"Neptuno": 0.15
}

var sol_nodo: Node2D = null
var rng = RandomNumberGenerator.new()

var planetas_instanciados: Dictionary = {}
var planeta_seleccionado: Node2D = null

func _ready():
	rng.randomize()
	
	sol_nodo = SOL_SCENE.instantiate()
	add_child(sol_nodo)
	sol_nodo.global_position = Vector2.ZERO
	sol_nodo.masa = SOL_DATOS.masa
	
	if sol_nodo.has_node("AnimatedSprite2D") and SOL_DATOS.has("sprite_frames_path") and FileAccess.file_exists(SOL_DATOS.sprite_frames_path):
		var sol_sprite_node = sol_nodo.get_node("AnimatedSprite2D")
		sol_sprite_node.sprite_frames = load(SOL_DATOS.sprite_frames_path)
		sol_sprite_node.play("default")
		sol_sprite_node.scale = Vector2(SOL_DATOS.scale_factor, SOL_DATOS.scale_factor)
	
	for datos in DATOS_PLANETAS:
		var planeta = PLANETA_SCENE.instantiate()
		planeta.name = datos.nombre
		add_child(planeta)
		
		planeta.masa = datos.masa
		
		if planeta.has_node("AnimatedSprite2D") and datos.has("sprite_frames_path") and FileAccess.file_exists(datos.sprite_frames_path):
			var sprite_node = planeta.get_node("AnimatedSprite2D")
			sprite_node.sprite_frames = load(datos.sprite_frames_path)
			sprite_node.play("default")
			sprite_node.scale = Vector2(datos.scale_factor, datos.scale_factor)
		
		planeta.sol = sol_nodo
		
		#Angulo Aleatorio
		var angulo_aleatorio_inicial = rng.randf_range(0.0, PI * 2)
		planeta.angulo_actual = angulo_aleatorio_inicial
		
		var nueva_x = datos.radio * cos(angulo_aleatorio_inicial)
		var nueva_y = datos.radio * sin(angulo_aleatorio_inicial)
		
		# Asigna el radio y la velocidad para el movimiento circular manual
		planeta.radio_orbita = datos.radio
		planeta.velocidad_orbital = VELOCIDADES_ORBITALES[datos.nombre]
		planeta.global_position = sol_nodo.global_position + Vector2(nueva_x, nueva_y)
		
		# Almacenar planetas y desaturar para el selector
		planetas_instanciados[datos.nombre] = planeta
		planeta.set_saturacion(false)
		
	if not planetas_instanciados.is_empty():
		var primer_planeta = planetas_instanciados.values()[0]
		seleccionar_planeta(primer_planeta)
		
func seleccionar_planeta(nuevo_planeta: Node2D):
	if planeta_seleccionado:
		planeta_seleccionado.set_saturacion(false)
	planeta_seleccionado = nuevo_planeta
	planeta_seleccionado.set_saturacion(true)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if planeta_seleccionado:
				var direccion = get_global_mouse_position() - planeta_seleccionado.global_position
				planeta_seleccionado.disparar(direccion)
				
