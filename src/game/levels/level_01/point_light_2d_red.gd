extends PointLight2D

func _ready():
	start_blinking()

func start_blinking():
	var tween = create_tween().set_loops() # set_loops() hace que sea infinito
	
	# Bajar la energía a 0 en 0.5 segundos
	tween.tween_property(self, "energy", 0.0, 0.5)
	
	# Subir la energía a 1 en 0.5 segundos
	tween.tween_property(self, "energy", 3.0, 0.5)
