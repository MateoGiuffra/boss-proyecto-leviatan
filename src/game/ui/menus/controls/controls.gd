extends MarginContainer
class_name ControlsMenu

@export var action_input_scene: PackedScene
signal back
@onready var action_input_container: VBoxContainer = $PanelContainer/SubMenuContainer/VBoxContainer/ScrollContainer/ActionInputContainer

func _ready() -> void:
	set_current_key("derecha")
	set_current_key("izquierda")
	set_current_key("dash")
	set_current_key("sacar_foto")
	set_current_key("saltar")

	await get_tree().process_frame

func _update_text(label: Label) -> void:
	if label == null:
		return

	if label.text.contains("(physical)"):
		label.text = normalize_text(label.text)

func normalize_text(text: String) -> String:
	return text.replace("_", " ").strip_escapes().replace("(physical)", "").capitalize()

func set_current_key(action_name: String) -> void:
	if action_name == "":
		return

	if not InputMap.has_action(action_name):
		return

	if action_input_scene == null:
		return

	if action_input_container == null:
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

	var action_input := action_input_scene.instantiate()
	action_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_input.custom_minimum_size = Vector2(0, 55)
	action_input_container.add_child(action_input)

	if action_input.has_method("init"):
		action_input.init(action_name, keys_text)

func set_current_movement_key(key_binding: String) -> void:
	set_current_key(key_binding)

func _on_exit_button_pressed() -> void:
	back.emit()

func play_fade() -> void:
	self.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1)
