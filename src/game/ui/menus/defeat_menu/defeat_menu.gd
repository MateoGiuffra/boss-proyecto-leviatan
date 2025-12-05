extends Control
@onready var you_lost_: Label = $"MarginContainer/VBoxContainer/You Lost!"

## Menú de derrota genérico. Solo se presenta si detecta que
## el Player llegó a 0 de HP.

signal retry_selected()
signal return_selected()


func _ready() -> void:
	hide()
	GameState.level_lost.connect(_on_level_lost)

func _on_level_lost():
	var player: Player = GameState.current_player
	var message: String = player.get_defeat_message()
	you_lost_.text = message
	show()

func _on_back_to_menu_button_pressed() -> void:
	return_selected.emit()


func _on_retry_button_pressed() -> void:
	retry_selected.emit() 
