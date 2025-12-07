# InputMapLoader.gd
extends Node

const CONFIG_FILE_PATH := "user://controls.cfg"
const INPUT_SECTION := "InputBindings"

# =====================================================
#                  CARGAR MAPEO
#   Llamar una vez al inicio del juego (ej. _ready)
# =====================================================
func load_input_map() -> void:
	var config := ConfigFile.new()
	var err := config.load(CONFIG_FILE_PATH)
	if err != OK:
		return  # No hay archivo todavía, usar bindings por defecto
	
	var actions: Array[StringName] = InputMap.get_actions()
	for action in actions:
		var key := String(action)
		if not config.has_section_key(INPUT_SECTION, key):
			continue
		
		var raw_array = config.get_value(INPUT_SECTION, key, [])
		if typeof(raw_array) != TYPE_ARRAY:
			continue
		
		var new_events: Array[InputEvent] = []
		
		for raw_entry in raw_array:
			# Compatibilidad: si alguna vez guardaste InputEvent crudo
			if raw_entry is InputEvent:
				new_events.append(raw_entry)
			elif typeof(raw_entry) == TYPE_DICTIONARY:
				var ev := _deserialize_event(raw_entry)
				if ev:
					new_events.append(ev)
		
		if new_events.is_empty():
			continue
		
		# Reemplazamos TODO el binding de la acción por lo que está en el archivo
		InputMap.action_erase_events(action)
		for ev in new_events:
			InputMap.action_add_event(action, ev)


# =====================================================
#                  GUARDAR MAPEO
#   Llamar cuando el usuario cambia un control
#   (ej. desde el script del botón)
# =====================================================
func save_input_map(action_name: StringName) -> void:
	var action_str := String(action_name)
	
	# 1) Tomar los eventos actuales de la acción
	var current_events: Array = InputMap.action_get_events(action_name)
	var chosen_event: InputEvent = null
	
	# Elegimos UN SOLO evento para esta acción
	for ev in current_events:
		if ev is InputEvent:
			chosen_event = ev
			break
	
	# 2) Normalizamos: en InputMap dejamos exactamente UN evento (o ninguno)
	InputMap.action_erase_events(action_name)
	var events_to_save: Array = []
	
	if chosen_event:
		InputMap.action_add_event(action_name, chosen_event)
		events_to_save.append(_serialize_event(chosen_event))
	# Si no hay chosen_event, la acción queda sin binding, y guardamos array vacío.
	
	# 3) Cargamos archivo existente para no perder otras acciones
	var config := ConfigFile.new()
	var _err := config.load(CONFIG_FILE_PATH) # si no existe, _err != OK, pero igual seguimos
	
	# 4) Guardamos la nueva lista de eventos (0 o 1) para esa acción
	config.set_value(INPUT_SECTION, action_str, events_to_save)
	
	# 5) Escribimos archivo
	config.save(CONFIG_FILE_PATH)


# =====================================================
#           SERIALIZACIÓN DE InputEvent
# =====================================================

func _serialize_event(event: InputEvent) -> Dictionary:
	var data: Dictionary = {}
	
	if event is InputEventKey:
		var e := event as InputEventKey
		data.type = "key"
		data.keycode = e.keycode
		data.physical_keycode = e.physical_keycode
		data.alt = e.alt_pressed
		data.shift = e.shift_pressed
		data.ctrl = e.ctrl_pressed
		data.meta = e.meta_pressed
	
	elif event is InputEventMouseButton:
		var e_mb := event as InputEventMouseButton
		data.type = "mouse_button"
		data.button_index = e_mb.button_index
		# Nombre correcto en Godot 4:
		data.double_click = e_mb.double_click
		data.alt = e_mb.alt_pressed
		data.shift = e_mb.shift_pressed
		data.ctrl = e_mb.ctrl_pressed
		data.meta = e_mb.meta_pressed
	
	elif event is InputEventJoypadButton:
		var e_jb := event as InputEventJoypadButton
		data.type = "joypad_button"
		data.button_index = e_jb.button_index
	
	elif event is InputEventJoypadMotion:
		var e_jm := event as InputEventJoypadMotion
		data.type = "joypad_motion"
		data.axis = e_jm.axis
		data.axis_value = e_jm.axis_value
	
	else:
		# Por si aparece algo raro/no soportado
		data.type = "unknown"
	
	return data


func _deserialize_event(data: Dictionary) -> InputEvent:
	var t = data.get("type", "")
	
	match t:
		"key":
			var e := InputEventKey.new()
			e.keycode = data.get("keycode", 0)
			e.physical_keycode = data.get("physical_keycode", 0)
			e.alt_pressed = data.get("alt", false)
			e.shift_pressed = data.get("shift", false)
			e.ctrl_pressed = data.get("ctrl", false)
			e.meta_pressed = data.get("meta", false)
			return e
		
		"mouse_button":
			var e_mb := InputEventMouseButton.new()
			e_mb.button_index = data.get("button_index", 0)
			# Nombre correcto: double_click
			e_mb.double_click = data.get("double_click", false)
			e_mb.alt_pressed = data.get("alt", false)
			e_mb.shift_pressed = data.get("shift", false)
			e_mb.ctrl_pressed = data.get("ctrl", false)
			e_mb.meta_pressed = data.get("meta", false)
			return e_mb
		
		"joypad_button":
			var e_jb := InputEventJoypadButton.new()
			e_jb.button_index = data.get("button_index", 0)
			return e_jb
		
		"joypad_motion":
			var e_jm := InputEventJoypadMotion.new()
			e_jm.axis = data.get("axis", 0)
			e_jm.axis_value = data.get("axis_value", 0.0)
			return e_jm
		
		_:
			return null
