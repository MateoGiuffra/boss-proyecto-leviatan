extends Control
@onready var controls: Control = $OptionsMenu/Controls
@onready var volume: Control = $OptionsMenu/Volume
@onready var general_options: VBoxContainer = $OptionsMenu/GeneralOptions

func _ready():
	hide()

func _on_options_button_pressed() -> void:
	show()
	controls.hide()
	volume.hide()

func _on_exit_button_pressed() -> void:
	hide()

func _on_volume_button_pressed() -> void:
	general_options.hide()
	volume.show()

func _on_controls_button_pressed() -> void:
	general_options.hide()
	controls.show()

func _on_volume_back_button_pressed() -> void:
	general_options.show()
	volume.hide()

func _on_control_back_button_pressed() -> void:
	general_options.show()
	controls.hide()
