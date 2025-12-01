extends Control
@onready var controls: Control = $OptionsMenu/Controls
@onready var volume: Control = $OptionsMenu/Volume
@onready var general_options: VBoxContainer = $OptionsMenu/Options/VBoxContainer/GeneralOptions
@onready var main_label: Label = $OptionsMenu/Options/VBoxContainer/Label


func _ready():
	hide()
	controls.hide()
	volume.hide()

func _on_options_button_pressed() -> void:
	show()
	controls.hide()
	volume.hide()

func _on_exit_button_pressed() -> void:
	hide()

func _on_volume_button_pressed() -> void:
	_hide()
	volume.show()

func _hide() -> void:
	general_options.hide()
	main_label.hide()

func _on_controls_button_pressed() -> void:
	_hide()
	controls.show()

func _show():
	general_options.show()
	main_label.show()

func _on_volume_back_button_pressed() -> void:
	_show()
	volume.hide()

func _on_control_back_button_pressed() -> void:
	_show()
	controls.hide()
