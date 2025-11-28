extends Control

const NIVEL_SCENE = "res://escenas/niveles/nivel_1.tscn"
const RUTA_ARCHIVO = "user://mejores_puntajes.save"

@onready var menu_botones = $ContenedorPrincipal/ContenedorBotones
@onready var logo = $Logo
@onready var panel_puntajes = $PanelPuntajes
@onready var lista_puntajes = $PanelPuntajes/VBoxContainer/ItemList
@onready var boton_cerrar_puntajes = $PanelPuntajes/VBoxContainer/BotonCerrarPuntajes
@onready var panel_lore = $PanelLore
@onready var boton_cerrar_lore = $PanelLore/VBoxContainer/BotonCerrarLore
@onready var sonido_inicio = $SonidoInicio
@onready var sonido_pato = $SonidoPato

func _ready():
	if panel_puntajes:
		panel_puntajes.visible = false
	if boton_cerrar_puntajes and not boton_cerrar_puntajes.pressed.is_connected(_on_boton_cerrar_puntajes_pressed):
		boton_cerrar_puntajes.pressed.connect(_on_boton_cerrar_puntajes_pressed)
	if sonido_inicio:
		sonido_inicio.play()

func _on_jugar_pressed():
	print("Cargando nivel...")
	get_tree().change_scene_to_file(NIVEL_SCENE)

func _on_salir_pressed():
	get_tree().quit()
	pass 

func _on_puntajes_pressed():
	if menu_botones: menu_botones.visible = false
	if panel_puntajes: panel_puntajes.visible = true
	mostrar_puntajes()

func _on_boton_cerrar_puntajes_pressed():
	if panel_puntajes: panel_puntajes.visible = false
	if menu_botones: menu_botones.visible = true
	
func mostrar_puntajes():
	if not lista_puntajes:
		print("Error: No se encuentra el nodo ItemList")
		return
	
	lista_puntajes.clear()
	
	if not FileAccess.file_exists(RUTA_ARCHIVO):
		print("El archivo de guardado no existe en: ", RUTA_ARCHIVO) 
		lista_puntajes.add_item("No hay puntajes registrados.")
		lista_puntajes.add_item("¡Juega una partida para crear la tabla!")
		return

	var archivo = FileAccess.open(RUTA_ARCHIVO, FileAccess.READ)
	if archivo:
		var texto_json = archivo.get_as_text()
		archivo.close()
		
		var json = JSON.new()
		var error = json.parse(texto_json)
		
		if error == OK:
			var datos = json.get_data()
			if typeof(datos) == TYPE_ARRAY:
				for i in range(datos.size()):
					var registro = datos[i]
					# Formato: "1. Nombre - 100 pts"
					var texto = "%d. %s - %d pts" % [i+1, registro["nombre"], registro["puntos"]]
					lista_puntajes.add_item(texto)
			else:
				lista_puntajes.add_item("Error en formato de datos.")
		else:
			lista_puntajes.add_item("Error al leer archivo.")


func _on_boton_cerrar_lore_pressed():
	if logo: logo.visible = true
	if panel_lore: panel_lore.visible = false
	if boton_cerrar_lore: boton_cerrar_lore.visible = true
	if sonido_pato: sonido_pato.stop()


func _on_contexto___pressed():
	if menu_botones: menu_botones.visible = false
	if logo: logo.visible = false
	if panel_lore: panel_lore.visible = true
	if sonido_pato: sonido_pato.play()
