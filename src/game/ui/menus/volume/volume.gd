extends MarginContainer
class_name VolumeMenu
signal back

func _on_volume_back_button_pressed() -> void:
	back.emit()
