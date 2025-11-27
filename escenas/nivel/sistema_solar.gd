extends Node2D

const SOL_SCENE = preload("res://escenas/planeta/sol.tscn")
const PLANETA_SCENE = preload("res://escenas/planeta/planeta.tscn")

const SOL_DATOS = {
	"masa": 250.0,
	"sprite_frames_path": "res://sprite_frames/sol.tres",
	"scale_factor": 1.5
}

const DATOS_PLANETAS = [
	{ "nombre": "Mercurio", "radio": 350.0, "masa": 0.1, "sprite_frames_path": "res://sprite_frames/mercurio.tres", "scale_factor": 0.3 },
	{ "nombre": "Venus","radio": 500.0, "masa": 0.3, "sprite_frames_path": "res://sprite_frames/venus.tres", "scale_factor": 0.5 },
	{ "nombre": "Tierra","radio": 650.0, "masa": 0.5, "sprite_frames_path": "res://sprite_frames/tierra.tres", "scale_factor": 0.55 },
	{ "nombre": "Marte","radio": 800.0, "masa": 0.2, "sprite_frames_path": "res://sprite_frames/marte.tres", "scale_factor": 0.4 },
	{ "nombre": "Jupiter","radio": 1100.0, "masa": 2.5, "sprite_frames_path": "res://sprite_frames/jupiter.tres", "scale_factor": 1.0 },
	{ "nombre": "Saturno","radio": 1500.0, "masa": 1.8, "sprite_frames_path": "res://sprite_frames/saturno.tres", "scale_factor": 0.8 },
	{ "nombre": "Urano","radio": 1950.0, "masa": 1.2, "sprite_frames_path": "res://sprite_frames/urano.tres", "scale_factor": 0.7 },
	{ "nombre": "Neptuno","radio": 2400.0, "masa": 1.1, "sprite_frames_path": "res://sprite_frames/neptuno.tres", "scale_factor": 0.5 }
]

const VELOCIDADES_ORBITALES = {
	"Mercurio": 0.9,
	"Venus": 0.6,
	"Tierra": 0.5,
	"Marte": 0.45,
	"Jupiter": 0.25,
	"Saturno": 0.175,
	"Urano": 0.125,
	"Neptuno": 0.072
}

var sol_nodo: Area2D = null
var rng = RandomNumberGenerator.new()

var planetas_instanciados: Dictionary = {}
var planeta_seleccionado: Area2D = null

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
		planeta.sol = sol_nodo
		planeta.radio_orbita = datos.radio
		planeta.velocidad_orbital = VELOCIDADES_ORBITALES[datos.nombre]
		
		if planeta.has_node("AnimatedSprite2D") and datos.has("sprite_frames_path") and FileAccess.file_exists(datos.sprite_frames_path):
			var sprite_node = planeta.get_node("AnimatedSprite2D")
			sprite_node.sprite_frames = load(datos.sprite_frames_path)
			sprite_node.play("default")
			sprite_node.scale = Vector2(datos.scale_factor, datos.scale_factor)
			if planeta.has_node("CollisionShape2D"):
				var hitbox = planeta.get_node("CollisionShape2D")
				var textura = sprite_node.sprite_frames.get_frame_texture("default", 0)
				var radio_imagen = textura.get_width() / 2.0
				var forma_circular = CircleShape2D.new()
				forma_circular.radius = radio_imagen
				hitbox.shape = forma_circular
				hitbox.scale = Vector2(datos.scale_factor, datos.scale_factor)
				hitbox.add_to_group("cuerpos_celestes")
		else:
			print("Advertencia: El planeta ", datos.nombre, " no tiene CollisionShape2D")
		#Angulo aleatorio
		var angulo_aleatorio_inicial = rng.randf_range(0.0, PI * 2)
		planeta.angulo_actual = angulo_aleatorio_inicial
		
		planeta.sol = sol_nodo
		
		var nueva_x = datos.radio * cos(angulo_aleatorio_inicial)
		var nueva_y = datos.radio * sin(angulo_aleatorio_inicial)
		planeta.global_position = sol_nodo.global_position + Vector2(nueva_x, nueva_y)
		
		# Almacenar
		planetas_instanciados[datos.nombre] = planeta
		planeta.set_saturacion(false)
		# Asigna el radio y la velocidad para el movimiento circular manual
		planeta.radio_orbita = datos.radio
		planeta.velocidad_orbital = VELOCIDADES_ORBITALES[datos.nombre]
		planeta.inicializar_datos()
		# Almacenar planetas y desaturar para el selector
		planetas_instanciados[datos.nombre] = planeta
		planeta.set_saturacion(false)
		
	if not planetas_instanciados.is_empty():
		var primer_planeta = planetas_instanciados.values()[0]
		seleccionar_planeta(primer_planeta)

func seleccionar_planeta(nuevo_planeta: Area2D):
	if "en_zona_activa" in nuevo_planeta and not nuevo_planeta.en_zona_activa:
		print("No se puede seleccionar: El planeta está en la zona oscura.")
		return
	if planeta_seleccionado:
		planeta_seleccionado.set_saturacion(false)
	planeta_seleccionado = nuevo_planeta
	if planeta_seleccionado:
		planeta_seleccionado.set_selected(true)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if planeta_seleccionado:
				var direccion = get_global_mouse_position() - planeta_seleccionado.global_position
				planeta_seleccionado.disparar(direccion)
