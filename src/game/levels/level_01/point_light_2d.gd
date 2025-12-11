extends PointLight2D

@export var min_energy: float = 0.8
@export var max_energy: float = 1.2
@export var flicker_speed: float = 0.1 # Qué tan rápido cambia

var time_passed: float = 0.0

func _process(delta):
	time_passed += delta
	
	# Usamos una función de ruido simple para variar la energía
	# randf() añade un poco de caos extra para que no sea un patrón perfecto
	if time_passed > flicker_speed:
		energy = randf_range(min_energy, max_energy)
		
		# Ocasionalmente (10% de probabilidad) apagarla casi del todo para dar efecto de fallo
		if randf() > 0.9:
			energy = 0.1
			
		time_passed = 0.0
