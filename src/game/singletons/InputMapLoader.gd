# InputMapLoader.gd
extends Node

const CONFIG_FILE_PATH = "user://controls.cfg"
const INPUT_SECTION = "InputBindings"

# ----------------------------------------------------
# Llamar al inicio del juego (ej. en _ready de MainScene)
# ----------------------------------------------------
func load_input_map() -> void:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE_PATH)
	
	if err != OK:
		return

	var actions: Array[StringName] = InputMap.get_actions()
	
	for action in actions:
		if config.has_section_key(INPUT_SECTION, action):
			var events_array: Array = config.get_value(INPUT_SECTION, action)
			
			# 1. Borramos las asignaciones actuales de esa acción
			InputMap.action_erase_events(action)
			
			# 2. Añadimos los eventos guardados por el usuario
			for event in events_array:
				if event is InputEvent:
					InputMap.action_add_event(action, event)
					
# ----------------------------------------------------
# Llamar desde el script del botón cada vez que cambia un control
# ----------------------------------------------------
func save_input_map(action_name: StringName) -> void:
	var config = ConfigFile.new()
	var events_to_save: Array = []
	
	var events: Array[InputEvent] = InputMap.action_get_events(action_name)
	
	# Solo guardamos el primer evento asignado a la acción
	for event in events:
		if event is InputEvent:
			events_to_save.append(event)
			break 

	# 1. Cargamos el archivo existente para mantener otras asignaciones
	var err = config.load(CONFIG_FILE_PATH)
	if err != OK:
		pass # Archivo no existe, se creará uno nuevo

	# 2. Guardamos la nueva asignación
	config.set_value(INPUT_SECTION, action_name, events_to_save)
	
	# 3. Guardamos el archivo en la ruta de usuario
	config.save(CONFIG_FILE_PATH)
