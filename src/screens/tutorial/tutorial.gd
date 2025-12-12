extends Control
class_name Tutorial

@export var level_manager_scene: PackedScene
@export var action_and_keys_scene: PackedScene
@onready var actions_and_keys_container: HFlowContainer = $MarginContainer/PanelContainer/VBoxContainer/CardsContainer/VBoxContainer/ActionsAndKeysContainer

func play_fade() -> void: 
	self.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1)

func _ready():
	self.visible = false
	self.modulate.a = 0.0
	set_current_key("derecha")
	set_current_key("izquierda")
	set_current_key("dash")
	set_current_key("sacar_foto")
	set_current_key("saltar")

func _update_text(label: Label) -> void:
	if label and label.text.contains("(physical)"):
		label.text = normalize_text(label.text)

func normalize_text(text: String) -> String:
	return text.replace("_", " ").strip_escapes().replace("(physical)", "").capitalize()
	
func set_current_key(action_name: String) -> void:
	if not InputMap.has_action(action_name):
		return

	var keys_text: Array[String] = []

	for ev in InputMap.action_get_events(action_name):
		if ev is InputEventKey:
			var code = ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode
			var key_str := OS.get_keycode_string(code)

			if key_str != "" and not keys_text.has(key_str):
				keys_text.append(key_str)

	if keys_text.is_empty():
		return

	var action_and_keys: ActionAndKeys = action_and_keys_scene.instantiate()
	actions_and_keys_container.add_child(action_and_keys)
	action_and_keys.init(action_name, keys_text)


func set_current_movement_key(key_binding: String ) -> void:
	set_current_key(key_binding)
		
func _on_new_scene_pressed() -> void:
	get_tree().change_scene_to_packed(level_manager_scene)
