extends Control

func _ready():
	hide()

func _on_options_button_pressed() -> void:
	show()

func _on_exit_button_pressed() -> void:
	hide()
