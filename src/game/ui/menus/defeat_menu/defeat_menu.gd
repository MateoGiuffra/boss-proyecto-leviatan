extends Control
@onready var you_lost_: Label = $"MarginContainer/VBoxContainer/You Lost!"

## Menú de derrota genérico. Solo se presenta si detecta que
## el Player llegó a 0 de HP.

signal retry_selected()
signal return_selected()
var message_show: bool = false

func _ready() -> void:
	hide()
	GameState.level_lost.connect(_on_level_lost)

func _on_level_lost():
	if not message_show:
		var player: Player = GameState.current_player
		var message: String = get_defeat_message(player)
		you_lost_.text = message
		message_show = true 
		show()
	
func get_defeat_message(player: Player) -> String:
	var die_messages: Array[String] = [
		"¡Has sido devorado!", 
		"¡Tu alma ha sido reclamada!",
		"¡El vacío te consumió!",
		"¡Has caído en combate!"
	]
	
	var oxygen_messages: Array[String] = [
		"¡Te quedaste sin oxígeno!",
		"¡El aire te falló!",
		"¡No pudiste contener la respiración!",
		"¡La presión te ahogó!",
		"¡Tus pulmones no resistieron!"
	]
	
	if player.hp <= 0:	
		return die_messages.pick_random()
	elif player.oxygen <= 0:	
		return oxygen_messages.pick_random()
	else:
		return "¡Tu alma ha sido reclamada!"

func _on_back_to_menu_button_pressed() -> void:
	return_selected.emit()
	message_show = false

func _on_retry_button_pressed() -> void:
	retry_selected.emit() 
	message_show = false
