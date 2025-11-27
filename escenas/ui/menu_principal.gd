extends Control

const NIVEL_SCENE = "res://escenas/niveles/nivel_1.tscn"

func _on_jugar_pressed():
	print("Cargando nivel...")
	get_tree().change_scene_to_file(NIVEL_SCENE)
	pass # Replace with function body.


func _on_salir_pressed():
	get_tree().quit()
	pass # Replace with function body.


func _on_cargar_pressed():
	pass # Replace with function body.


func _on_puntajes_pressed():
	pass # Replace with function body.
