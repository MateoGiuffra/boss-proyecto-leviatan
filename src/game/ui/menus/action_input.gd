@tool
extends Button

@onready var action_label: Label = $MarginContainer/HBoxContainer/Action as Label
@onready var input_label: Label = $MarginContainer/HBoxContainer/InputContainer/Input as Label

@export var action_name: String = "Saltar"
@export var input_default_text: String = "Espacio"
var has_to_normalize = true

func get_normalized_action_name() -> String:
	return normalize_input(action_name)

func normalize_input(text:String) -> String:
	var result = text.to_snake_case().to_lower().strip_escapes().replace("(physical)", "")
	return result

func normalize_text(text: String) -> String:
	var result = text.replace("_", " ").strip_escapes().replace("(physical)", "").capitalize()
	return result

func _physics_process(_delta: float) -> void:
	if !has_to_normalize: 
		pass
	action_label.text = normalize_text(action_label.text)
	input_label.text = normalize_text(input_label.text)
	has_to_normalize = action_label.text.contains("(physical)") or input_label.text.contains("(physical)")
	

func _ready() -> void:
	set_process_unhandled_input(false)
	
	action_label.text = normalize_text(action_name)
	input_label.text = normalize_text(input_default_text)
	
	var input_map_action: String = get_normalized_action_name()
	
	if !Engine.is_editor_hint() and InputMap.has_action(input_map_action):
		var event_list: Array[InputEvent] = InputMap.action_get_events(input_map_action)
		
		if not event_list.is_empty():
			var event: InputEvent = event_list[0]
			_set_event(event)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or !event.is_pressed() or event.is_echo():
		return
		
	var input_map_action: String = get_normalized_action_name()
		
	InputMap.action_erase_events(input_map_action)
	InputMap.action_add_event(input_map_action, event)
	
	_set_event(event)
	
	InputMapLoader.save_input_map(input_map_action)
	
	get_viewport().set_input_as_handled()
	set_process_unhandled_input(false)

func _set_event(event: InputEvent) -> void:
	input_label.text = normalize_text(event.as_text())

func _on_pressed() -> void:
	set_process_unhandled_input(true)
	input_label.text = "..."
