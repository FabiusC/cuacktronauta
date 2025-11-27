extends Button

@onready var icono_salud = $IconoSalud

func _ready():
	if icono_salud:
		icono_salud.frame = 4

func actualizar_icono_salud(vida_actual: int):
	if icono_salud:
		var frame_destino = clamp(vida_actual-1, 0, 4)
		icono_salud.frame = frame_destino
