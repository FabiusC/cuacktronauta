extends RigidBody2D

@export var masa: float = 1000000.0
@export var radio_orbita: float = 0.0
@export var velocidad_inicial: float = 0.0

var sol: RigidBody2D = null
const G: float = 6.67430e-11
const ESCALA_GRAVEDAD: float = 1000.0

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if sol != null:
		# Calcular la dirección y distancia al Sol
		var direccion_al_sol = sol.global_position - global_position
		var distancia_cuadrada = direccion_al_sol.length_squared()
		
		# Evitar división por cero
		if distancia_cuadrada < 1.0:
			distancia_cuadrada = 1.0
			
		var magnitud_fuerza = (G * sol.masa * masa) / distancia_cuadrada
		
		# Calcular el vector de la fuerza y aplicar el escalado
		var fuerza_gravitacional = direccion_al_sol.normalized() * magnitud_fuerza * ESCALA_GRAVEDAD
		
		# Aplica la fuerza al cuerpo rígido
		state.apply_central_force(fuerza_gravitacional)
