extends Control

const NIVEL_SCENE = "res://escenas/niveles/nivel_1.tscn"
const RUTA_ARCHIVO = "user://mejores_puntajes.save"

@onready var menu_botones = $VBoxContainer
@onready var panel_puntajes = $PanelPuntajes
@onready var lista_puntajes = $PanelPuntajes/ItemList
@onready var boton_cerrar_puntajes = $PanelPuntajes/BotonCerrar

func _ready():
	if panel_puntajes:
		panel_puntajes.visible = false
	if boton_cerrar_puntajes and not boton_cerrar_puntajes.pressed.is_connected(_on_boton_cerrar_puntajes_pressed):
		boton_cerrar_puntajes.pressed.connect(_on_boton_cerrar_puntajes_pressed)

func _on_jugar_pressed():
	print("Cargando nivel...")
	get_tree().change_scene_to_file(NIVEL_SCENE)

func _on_salir_pressed():
	get_tree().quit()
	pass 

func _on_cargar_pressed():
	pass

func _on_puntajes_pressed():
	if menu_botones: menu_botones.visible = false
	if panel_puntajes: panel_puntajes.visible = true
	mostrar_puntajes()
	pass 

func _on_boton_cerrar_puntajes_pressed():
	if panel_puntajes: panel_puntajes.visible = false
	if menu_botones: menu_botones.visible = true
	
func mostrar_puntajes():
	if not lista_puntajes: return
	lista_puntajes.clear()
	
	if not FileAccess.file_exists(RUTA_ARCHIVO):
		lista_puntajes.add_item("Aún no hay puntajes.")
		lista_puntajes.add_item("¡Juega para crear el archivo!")
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
					var texto = "%d. %s - %d" % [i+1, registro["nombre"], registro["puntos"]]
					lista_puntajes.add_item(texto)
