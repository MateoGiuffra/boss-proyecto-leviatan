extends HSlider

@export var text: String = "Sound"        
@export var bus_name: String = "Master"   

@onready var label: Label = $Label

func _ready() -> void:
	label.text = text

	# Configurar el rango del slider
	min_value = 0.0
	max_value = 1.0
	step = 0.01

	# Obtener volumen actual del bus y reflejarlo en el slider
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("El bus '%s' no existe." % bus_name)
		return

	var current_db := AudioServer.get_bus_volume_db(bus_index)
	value = db_to_linear(current_db)

	# Conectar el evento de cambio
	connect("value_changed", Callable(self, "_on_value_changed"))


func _on_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return

	var db := linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_index, db)


# --- Conversiones ---
func linear_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0
	return 20.0 * log(value)

func db_to_linear(db: float) -> float:
	return pow(10.0, db / 20.0)
