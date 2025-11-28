extends CanvasLayer

const RUTA_ARCHIVO = "user://mejores_puntajes.save"
const MENU_PRINCIPAL_PATH = "res://escenas/ui/menu_principal.tscn"
const NIVEL_1_PATH = "res://escenas/Niveles/nivel_1.tscn"

@onready var label_puntaje = $VBoxContainer/LabelPuntajeFinal
@onready var input_nombre = $VBoxContainer/InputNombre
@onready var boton_guardar = $VBoxContainer/BotonGuardar
@onready var lista_visual = $VBoxContainer/ListaPuntajes

var puntajes_guardados: Array = []

func _ready():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if label_puntaje:
		label_puntaje.text = "Puntaje Final: " + str(Global.puntos_actuales)
	
	cargar_puntajes()
	actualizar_lista_visual()
	
	if not boton_guardar.pressed.is_connected(_on_guardar_pressed):
		boton_guardar.pressed.connect(_on_guardar_pressed)

func crear_datos_por_defecto():
	puntajes_guardados = []
	for i in range(10):
		var letra = char(65 + i)
		var puntos = 10 - i
		var registro = { "nombre": "Jugador " + letra, "puntos": puntos }
		puntajes_guardados.append(registro)
	guardar_en_archivo()

func _on_guardar_pressed():
	var nombre_jugador = input_nombre.text
	if nombre_jugador.strip_edges() == "":
		nombre_jugador = "Anonimo"
	
	var nuevo_registro = { "nombre": nombre_jugador, "puntos": Global.puntos_actuales }
	puntajes_guardados.append(nuevo_registro)
	puntajes_guardados.sort_custom(ordenar_por_puntos)
	
	if puntajes_guardados.size() > 10:
		puntajes_guardados = puntajes_guardados.slice(0, 10)
	
	guardar_en_archivo()
	actualizar_lista_visual()
	
	boton_guardar.disabled = true
	input_nombre.editable = false
	boton_guardar.text = "¡Guardado!"

func ordenar_por_puntos(a, b):
	return a["puntos"] > b["puntos"] 

func cargar_puntajes():
	if not FileAccess.file_exists(RUTA_ARCHIVO):
		crear_datos_por_defecto()
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
				puntajes_guardados = datos
			else:
				crear_datos_por_defecto()
		else:
			crear_datos_por_defecto()

func guardar_en_archivo():
	var archivo = FileAccess.open(RUTA_ARCHIVO, FileAccess.WRITE)
	if archivo:
		var texto_json = JSON.stringify(puntajes_guardados, "\t")
		archivo.store_string(texto_json)
		archivo.close()

func actualizar_lista_visual():
	lista_visual.clear()
	for i in range(puntajes_guardados.size()):
		var dato = puntajes_guardados[i]
		var texto = "%d. %s - %d pts" % [i+1, dato["nombre"], dato["puntos"]]
		lista_visual.add_item(texto)

func _on_reiniciar_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_salir_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_PRINCIPAL_PATH)
