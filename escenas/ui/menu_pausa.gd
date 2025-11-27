extends CanvasLayer
const MENU_PRINCIPAL_SCENE = "res://escenas/ui/menu_principal.tscn"

func _ready():
	get_tree().paused = true
	
func _on_continuar_pressed():
	get_tree().paused = false
	queue_free()

func _on_ir_a_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_PRINCIPAL_SCENE)

func _on_salir_del_juego_pressed():
	get_tree().quit()
