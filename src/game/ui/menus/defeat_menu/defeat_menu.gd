extends Control

## Menú de derrota genérico. Solo se presenta si detecta que
## el Player llegó a 0 de HP.

signal retry_selected()
signal return_selected()


func _ready() -> void:
	hide()
	GameState.level_lost.connect(_on_level_lost)

func _on_level_lost():
	show()

func _on_back_to_menu_button_pressed() -> void:
	print("clicked")
	return_selected.emit()


func _on_retry_button_pressed() -> void:
	retry_selected.emit() 
