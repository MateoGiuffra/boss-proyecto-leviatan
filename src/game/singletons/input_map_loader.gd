extends Node

const CONFIG_FILE_PATH = "user://controls.cfg"
const INPUT_SECTION = "InputBindings"


func load_input_map() -> void:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE_PATH)
	if err != OK:
		return
	
	var actions: Array[StringName] = InputMap.get_actions()
	for action in actions:
		var key = String(action)
		if not config.has_section_key(INPUT_SECTION, key):
			continue
		
		var raw_array = config.get_value(INPUT_SECTION, key, [])
		if typeof(raw_array) != TYPE_ARRAY:
			continue
		
		var new_events: Array[InputEvent] = []
		for raw_entry in raw_array:
			if raw_entry is InputEvent:
				new_events.append(raw_entry)
			elif typeof(raw_entry) == TYPE_DICTIONARY:
				var ev = _deserialize_event(raw_entry)
				if ev:
					new_events.append(ev)
		
		if new_events.is_empty():
			continue
		
		InputMap.action_erase_events(action)
		for ev in new_events:
			InputMap.action_add_event(action, ev)


func save_input_map(action_name: StringName) -> void:
	var config = ConfigFile.new()
	var _err = config.load(CONFIG_FILE_PATH) # si no existe, se crea igual al guardar
	
	var events: Array = InputMap.action_get_events(action_name)
	var events_to_save: Array = []
	
	for ev in events:
		if ev is InputEvent:
			events_to_save.append(_serialize_event(ev))
	
	config.set_value(INPUT_SECTION, String(action_name), events_to_save)
	config.save(CONFIG_FILE_PATH)


# serializacion

func _serialize_event(event: InputEvent) -> Dictionary:
	var data = {}
	
	if event is InputEventKey:
		var e = event as InputEventKey
		data.type = "key"
		data.keycode = e.keycode
		data.physical_keycode = e.physical_keycode
		data.alt = e.alt_pressed
		data.shift = e.shift_pressed
		data.ctrl = e.ctrl_pressed
		data.meta = e.meta_pressed
	
	elif event is InputEventMouseButton:
		var e_mb = event as InputEventMouseButton
		data.type = "mouse_button"
		data.button_index = e_mb.button_index
		data.double_click = e_mb.double_click
		data.alt = e_mb.alt_pressed
		data.shift = e_mb.shift_pressed
		data.ctrl = e_mb.ctrl_pressed
		data.meta = e_mb.meta_pressed
	
	elif event is InputEventJoypadButton:
		var e_jb = event as InputEventJoypadButton
		data.type = "joypad_button"
		data.button_index = e_jb.button_index
	
	elif event is InputEventJoypadMotion:
		var e_jm = event as InputEventJoypadMotion
		data.type = "joypad_motion"
		data.axis = e_jm.axis
		data.axis_value = e_jm.axis_value
	
	else:
		data.type = "unknown"
	
	return data


func _deserialize_event(data: Dictionary) -> InputEvent:
	var t = data.get("type", "")
	
	match t:
		"key":
			var e = InputEventKey.new()
			e.keycode = data.get("keycode", 0)
			e.physical_keycode = data.get("physical_keycode", 0)
			e.alt_pressed = data.get("alt", false)
			e.shift_pressed = data.get("shift", false)
			e.ctrl_pressed = data.get("ctrl", false)
			e.meta_pressed = data.get("meta", false)
			return e
		
		"mouse_button":
			var e_mb = InputEventMouseButton.new()
			e_mb.button_index = data.get("button_index", 0)
			e_mb.double_click = data.get("double_click", false)
			e_mb.alt_pressed = data.get("alt", false)
			e_mb.shift_pressed = data.get("shift", false)
			e_mb.ctrl_pressed = data.get("ctrl", false)
			e_mb.meta_pressed = data.get("meta", false)
			return e_mb
		
		"joypad_button":
			var e_jb = InputEventJoypadButton.new()
			e_jb.button_index = data.get("button_index", 0)
			return e_jb
		
		"joypad_motion":
			var e_jm = InputEventJoypadMotion.new()
			e_jm.axis = data.get("axis", 0)
			e_jm.axis_value = data.get("axis_value", 0.0)
			return e_jm
		
		_:
			return null
