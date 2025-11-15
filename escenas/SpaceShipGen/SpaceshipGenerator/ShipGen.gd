extends Control

onready var ship_sprite = $HBoxContainer/ColorRect
onready var ship_material = ship_sprite.material

func _ready():
	randomize()

func _physics_process(delta):
	ship_sprite.rect_rotation += delta * 10.0

func _on_LineEdit_text_changed(new_text):
	ship_material.set_shader_param("seed", float(new_text)/1000.0)

func _on_Button_pressed():
	var sd = (randi()%100000)
	ship_material.set_shader_param("seed", sd/1000.0)
	$HBoxContainer/GUI/VBoxContainer/VBoxContainer/HBoxContainer/Seed/LineEdit.text = String(sd)

func _on_width_HSlider_value_changed(value):
	ship_material.set_shader_param("width", value)

func _on_height_HSlider_value_changed(value):
	ship_material.set_shader_param("height", value)

func _on_complexity_HSlider_value_changed(value):
	ship_material.set_shader_param("complexity", value)

func _on_size_HSlider_value_changed(value):
	ship_material.set_shader_param("alpha_cutoff", value)

func _on_MirrorX_toggled(on):
	ship_material.set_shader_param("mirrorX", on)

func _on_MirrorY_toggled(on):
	ship_material.set_shader_param("mirrorY", on)

func _on_Color1_color_changed(color):
	ship_material.set_shader_param("color1", color)

func _on_Color2_color_changed(color):
	ship_material.set_shader_param("color2", color)

func _on_BorderColor_color_changed(color):
	ship_material.set_shader_param("border_color", color)
