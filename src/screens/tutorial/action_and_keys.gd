extends PanelContainer
class_name ActionAndKeys
@export var key_container_scene: PackedScene 
@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer

@onready var title: Label = $MarginContainer/VBoxContainer/Title

@export var action: String = "Dash"
@export var keys: Array[String] = ["Shift"]

func ready() -> void:
	init(action, keys)

func normalize_text(text: String) -> String:
	return text.replace("_", " ").strip_escapes().replace("(physical)", "").capitalize()

func init(_action: String, _keys: Array[String]) -> void:
	title.text = normalize_text(_action)

	for key_text in _keys:
		var key_container = key_container_scene.instantiate()
		v_box_container.add_child(key_container)
		key_container.set_text(key_text)
