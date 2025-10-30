extends Control

## Menú de pausa genérico, abierto utilizando la acción "pause_menu"
## (por default la tecla Esc).
@onready var options_menu: Control = $OptionsMenu
signal return_selected()

func _ready() -> void:
	hide()

func _physics_process(delta: float) -> void:
	var ins  = InputEventAction.new()
	if ins.is_action_pressed("pause_menu"):
			print("holaa")
			visible = !visible
			get_tree().paused = visible
	ins.is_queued_for_deletion()
	
func _unhandled_key_input(event: InputEvent) -> void:
	print("holaa2")
	if event.is_action_released("pause_menu") && !options_menu.visible:
		visible = !visible
		get_tree().paused = visible


func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_return_button_pressed() -> void:
	return_selected.emit()
