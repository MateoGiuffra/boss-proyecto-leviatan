extends Control
@onready var volume: Control = $OptionsMenu/Volume
# @onready var main_label: Label = $OptionsMenu/Options/VBoxContainer/Label
@onready var options: MarginContainer = $OptionsMenu/Options
@onready var controls: ControlsMenu = $OptionsMenu/ControlsMenu

func _ready():
	hide()
	controls.back.connect(_on_control_back_button_pressed)
	volume.back.connect(_on_volume_back_button_pressed)
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
	options.hide()
	# # main_label.hide()

func _on_controls_button_pressed() -> void:
	_hide()
	controls.show()

func _show():
	options.show()
	# main_label.show()

func _on_volume_back_button_pressed() -> void:
	_show()
	volume.hide()

func _on_control_back_button_pressed() -> void:
	_show()
	controls.hide()
