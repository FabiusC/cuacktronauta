extends CanvasLayer

const SISTEMA_SOLAR_SCRIPT = preload("res://escenas/nivel/sistema_solar.gd")
const DATOS_PLANETAS = SISTEMA_SOLAR_SCRIPT.DATOS_PLANETAS

const BOTON_PLANETA_SCENE = preload("res://escenas/ui/boton_planeta.tscn")
@onready var contenedor_botones = $ContenedorBotones as HBoxContainer
@onready var sistema_solar = get_parent().get_node("SistemaSolar")

func _ready():
	generar_botones_planetas()
	
func generar_botones_planetas():
	if not sistema_solar:
		print("ERROR: No se encontró el nodo SistemaSolar para establecer la conexión.")
		return
		
	for datos in DATOS_PLANETAS:
		var boton = BOTON_PLANETA_SCENE.instantiate()
		boton.name = datos.nombre
		boton.custom_minimum_size = Vector2(80, 80)
		
		var sprite_node = boton.get_node("AnimatedSprite2D")
		
		if sprite_node:
			if datos.has("sprite_frames_path") and FileAccess.file_exists(datos.sprite_frames_path):
				sprite_node.sprite_frames = load(datos.sprite_frames_path)
				sprite_node.play("default")
				var factor_ui_grande = 1.0 
				var escala_ajustada = Vector2(datos.scale_factor, datos.scale_factor) * factor_ui_grande
				sprite_node.scale = escala_ajustada
			else:
				print("No encuuentra el SpriteFrames para ", datos.nombre)
				
		boton.pressed.connect(
			func():
				var planeta_nodo = sistema_solar.get_node(datos.nombre)
				if is_instance_valid(planeta_nodo):
					sistema_solar.seleccionar_planeta(planeta_nodo)
				else:
					print("ERROR: Planeta '", datos.nombre, "' no encontrado en SistemaSolar.")
		)
		contenedor_botones.add_child(boton)
