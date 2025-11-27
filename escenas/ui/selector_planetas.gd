extends CanvasLayer

const SISTEMA_SOLAR_SCRIPT = preload("res://escenas/nivel/sistema_solar.gd")
const DATOS_PLANETAS = [
	{ "nombre": "Mercurio", "radio": 100.0, "masa": 0.1, "sprite_frames_path": "res://sprite_frames/mercurio.tres", "scale_factor": 0.35 },
	{ "nombre": "Venus","radio": 100.0, "masa": 0.3, "sprite_frames_path": "res://sprite_frames/venus.tres", "scale_factor": 0.35 },
	{ "nombre": "Tierra","radio": 100.0, "masa": 0.5, "sprite_frames_path": "res://sprite_frames/tierra.tres", "scale_factor": 0.35 },
	{ "nombre": "Marte","radio": 100.0, "masa": 0.2, "sprite_frames_path": "res://sprite_frames/marte.tres", "scale_factor": 0.35 },
	{ "nombre": "Saturno","radio": 100.0, "masa": 1.8, "sprite_frames_path": "res://sprite_frames/saturno.tres", "scale_factor": 0.35 },
	{ "nombre": "Urano","radio": 100.0, "masa": 1.2, "sprite_frames_path": "res://sprite_frames/urano.tres", "scale_factor": 0.35 },
	{ "nombre": "Neptuno","radio": 100.0, "masa": 1.1, "sprite_frames_path": "res://sprite_frames/neptuno.tres", "scale_factor": 0.35 }
]

const BOTON_PLANETA_SCENE = preload("res://escenas/ui/boton_planeta.tscn")
@onready var contenedor_botones = $ContenedorBotones as VBoxContainer
@onready var sistema_solar = get_parent().get_node("SistemaSolar")

var boton_seleccionado: Node = null

func _ready():
	await get_tree().process_frame 
	generar_botones_planetas()
	actualizar_botones_color(null)
	
func generar_botones_planetas():
	if not sistema_solar:
		print("ERROR: No se encontró el nodo SistemaSolar para establecer la conexión.")
		return
	for hijo in contenedor_botones.get_children():
		hijo.queue_free()
	
	for datos in DATOS_PLANETAS:
		var boton = BOTON_PLANETA_SCENE.instantiate()
		boton.name = datos.nombre
		boton.custom_minimum_size = Vector2(80, 80)
		
		var sprite_node = boton.get_node("AnimatedSprite2D")
		
		if sprite_node:
			if datos.has("sprite_frames_path") and FileAccess.file_exists(datos.sprite_frames_path):
				sprite_node.sprite_frames = load(datos.sprite_frames_path)
				sprite_node.play("default")
				var factor_ui_grande = 0.6 #Tamano planeta en boton
				var escala_ajustada = Vector2(datos.scale_factor, datos.scale_factor) * factor_ui_grande
				sprite_node.scale = escala_ajustada
			else:
				print("No encuentra el SpriteFrames para ", datos.nombre)
		# Logica Salud
		var planeta_real = sistema_solar.get_node_or_null(datos.nombre)
		if boton.has_method("actualizar_icono_salud"):
				var vida_inicial = 4
				if "health" in planeta_real:
					vida_inicial = planeta_real.health
					if vida_inicial == 0 and not planeta_real.is_dead:
						vida_inicial = 4
				boton.actualizar_icono_salud(vida_inicial)
		var icono_salud = boton.get_node_or_null("IconoSalud")
		if not icono_salud:
			print("ERROR: El nodo 'IconoSalud' no existe dentro de boton_planeta.tscn")
		else:
			icono_salud.position = Vector2(60, 60)
			icono_salud.scale = Vector2(0.9, 0.9) # Tamano corazon en boton
		
		if planeta_real.has_signal("salud_cambiada"):
				if not planeta_real.is_connected("salud_cambiada", Callable(boton, "actualizar_icono_salud")):
					planeta_real.salud_cambiada.connect(boton.actualizar_icono_salud)
		else:
			print("Advertencia: No se encontró el planeta real ", datos.nombre)
		boton.pressed.connect(
			func():
				var planeta_nodo = sistema_solar.get_node(datos.nombre)
				if is_instance_valid(planeta_nodo):
					if planeta_nodo.en_zona_activa:
						sistema_solar.seleccionar_planeta(planeta_nodo)
						actualizar_botones_color(boton)
					else:
						print("Planeta fuera de alcance")
				else:
					print("ERROR: Planeta '", datos.nombre, "' no encontrado en SistemaSolar.")
		)
		contenedor_botones.add_child(boton)

func actualizar_botones_color(nuevo_boton_seleccionado: Node):
	for boton in contenedor_botones.get_children():
		var sprite = boton.get_node("AnimatedSprite2D")
		
		if sprite:
			if boton == nuevo_boton_seleccionado:
				sprite.modulate = Color.WHITE 
			else:
				sprite.modulate = Color(0.5, 0.5, 0.5, 1.0)

	boton_seleccionado = nuevo_boton_seleccionado
