@tool
extends Button

@onready var action_label: Label = $MarginContainer/HBoxContainer/Action
@onready var input_label: Label = $MarginContainer/HBoxContainer/InputContainer/Input

@export var action_name: String = "Saltar"
@export var input_default_text: String = "Espacio"

var has_to_normalize: bool = true
var previous_label_text: String = ""


func get_normalized_action_name() -> String:
	return normalize_input(action_name)


func normalize_input(text: String) -> String:
	var result = text.to_snake_case().to_lower().strip_escapes().replace("(physical)", "")
	return result


func normalize_text(text: String) -> String:
	var result = text.replace("_", " ").strip_escapes().replace("(physical)", "").capitalize()
	return result


func _physics_process(_delta: float) -> void:
	if not has_to_normalize:
		return

	action_label.text = normalize_text(action_label.text)
	input_label.text = normalize_text(input_label.text)
	has_to_normalize = false


func _ready() -> void:
	set_process_input(false)
	set_process_unhandled_input(false)
	
	action_label.text = normalize_text(action_name)
	input_label.text = normalize_text(input_default_text)
	has_to_normalize = true
	
	var input_map_action: String = get_normalized_action_name()
	
	if not Engine.is_editor_hint() and InputMap.has_action(input_map_action):
		var event_list: Array = InputMap.action_get_events(input_map_action)
		if not event_list.is_empty():
			var event: InputEvent = event_list[0]
			_set_event(event)


func _input(event: InputEvent) -> void:
	if not is_processing_input():
		return
	
	if event is InputEventMouseMotion:
		return
	
	if not event.is_pressed() or event.is_echo():
		return
	
	get_viewport().set_input_as_handled()
	set_process_input(false)
	
	var input_map_action: String = get_normalized_action_name()
	var new_key_string: String = _event_to_key_string(event)
	var is_duplicate: bool = false
	
	# 1) Ver si esta tecla ya está usada por OTRA acción
	var actions: Array = InputMap.get_actions()
	for other_action in actions:
		if String(other_action) == input_map_action:
			continue
		
		var events: Array = InputMap.action_get_events(other_action)
		for e in events:
			var other_key_string: String = _event_to_key_string(e)
			if other_key_string == new_key_string:
				is_duplicate = true
				break
		if is_duplicate:
			break
	
	if is_duplicate:
		# 2) Si está repetida, no cambiamos el binding:
		#    volvemos al texto anterior (lo que tenía antes de apretar "...")
		if previous_label_text != "":
			input_label.text = previous_label_text
			has_to_normalize = true
		else:
			# fallback por si acaso
			input_label.text = normalize_text(input_default_text)
			has_to_normalize = true
		return
	
	# 3) No hay duplicado: aplicamos el nuevo binding
	InputMap.action_erase_events(input_map_action)
	InputMap.action_add_event(input_map_action, event)
	
	_set_event(event)
	InputMapLoader.save_input_map(input_map_action)


func _event_to_key_string(ev: InputEvent) -> String:
	var txt: String = ev.as_text()
	# para comparación lógica ignoramos el "(physical)"
	txt = txt.replace("(Physical)", "").replace("(physical)", "").strip_edges()
	return txt


func _set_event(event: InputEvent) -> void:
	input_label.text = event.as_text()
	has_to_normalize = true


func _on_pressed() -> void:
	# Guardamos lo que tenía antes, para poder volver si hay duplicado
	previous_label_text = input_label.text
	
	set_process_input(true)
	input_label.text = "..."
	has_to_normalize = true
