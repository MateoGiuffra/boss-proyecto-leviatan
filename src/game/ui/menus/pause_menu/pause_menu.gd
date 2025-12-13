extends CanvasLayer

## Menú de pausa genérico, abierto utilizando la acción "pause_menu"
## (por default la tecla Esc).
@onready var options_menu: Control = $OptionsMenu
signal return_selected()
signal restart_requested()
@onready var hover_button: AudioStreamPlayer = $HoverButton

func _ready() -> void:
	connect_buttons_to_sound()
	hide()
	
func connect_buttons_to_sound():
	var buttons = get_tree().get_nodes_in_group("ButtonUI") 

	for button in buttons:
		if button:
			button.mouse_entered.connect(SoundManager.play_hover_sound.bind(hover_button))
			hover_button.bus = "UI"

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("pausar_menu") && !options_menu.visible:
		visible = !visible
		get_tree().paused = visible

func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_return_button_pressed() -> void:
		return_selected.emit()
		

func _on_options_button_pressed() -> void:
	options_menu.show()

func _on_restart_level_button_pressed() -> void:
	get_tree().paused = false
	restart_requested.emit()
	hide()
