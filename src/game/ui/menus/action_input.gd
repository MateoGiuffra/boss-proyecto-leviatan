extends Button

@onready var input_label: Label = $MarginContainer/HBoxContainer/InputLabel
@onready var action_label: Label = $MarginContainer/HBoxContainer/ActionLabel

@export var action_name: String = "Saltar"
@export var input_default_text: String = "Espacio"

var has_to_normalize: bool = true
var previous_label_text: String = ""

func init(_action_name: String, keys: Array[String]) -> void:
	if keys.is_empty():
		return

	var key: String = keys[0]
	action_label.text = _action_name
	action_name = _action_name

	input_default_text = key
	input_label.text = key

func _ready() -> void:
	init(action_name, [input_default_text])

	set_process_input(false)
	set_process_unhandled_input(false)

	action_label.text = normalize_text(action_name)
	input_label.text = normalize_text(input_default_text)
	has_to_normalize = true

	var input_map_action: String = get_normalized_action_name()

	if not Engine.is_editor_hint() and InputMap.has_action(input_map_action):
		var event_list: Array = InputMap.action_get_events(input_map_action)
		if not event_list.is_empty():
			var ev: InputEvent = event_list[0]
			_set_event(ev)

func _physics_process(_delta: float) -> void:
	if not has_to_normalize:
		return

	action_label.text = normalize_text(action_label.text)
	input_label.text = normalize_text(input_label.text)

	var a: String = action_label.text
	var i: String = input_label.text
	has_to_normalize = a.is_empty() or a.findn("(physical)") != -1 or i.is_empty() or i.findn("(physical)") != -1

func _input(event: InputEvent) -> void:
	if not is_processing_input():
		return

	# SOLO teclado
	if not (event is InputEventKey):
		return

	if not event.is_pressed() or event.is_echo():
		return

	get_viewport().set_input_as_handled()
	set_process_input(false)

	var input_map_action: String = get_normalized_action_name()
	var new_key_string: String = _event_to_key_string(event)
	var is_duplicate: bool = false

	# Ver duplicados en otras acciones
	for other_action in InputMap.get_actions():
		if String(other_action) == input_map_action:
			continue

		for e in InputMap.action_get_events(other_action):
			if _event_to_key_string(e) == new_key_string:
				is_duplicate = true
				break

		if is_duplicate:
			break

	if is_duplicate:
		if previous_label_text != "":
			input_label.text = previous_label_text
		else:
			input_label.text = normalize_text(input_default_text)

		has_to_normalize = true
		return

	# Aplicar nuevo binding (duplicamos el evento por seguridad)
	var ev := event.duplicate()
	InputMap.action_erase_events(input_map_action)
	InputMap.action_add_event(input_map_action, ev)

	_set_event(ev)
	InputMapLoader.save_input_map(input_map_action)

func _on_pressed() -> void:
	previous_label_text = input_label.text
	set_process_input(true)
	input_label.text = "..."
	has_to_normalize = true

func get_normalized_action_name() -> String:
	return normalize_input(action_name)

func normalize_input(_text: String) -> String:
	var result: String = _text.to_snake_case().to_lower().strip_escapes()
	return _strip_physical(result)

func normalize_text(_text: String) -> String:
	var result: String = _text.replace("_", " ").strip_escapes()
	return _strip_physical(result).capitalize()

func _strip_physical(s: String) -> String:
	return s.replace("(Physical)", "").replace("(physical)", "").strip_edges()

func _event_to_key_string(ev: InputEvent) -> String:
	return _strip_physical(ev.as_text())

func _set_event(event: InputEvent) -> void:
	input_label.text = _strip_physical(event.as_text())
	has_to_normalize = true
