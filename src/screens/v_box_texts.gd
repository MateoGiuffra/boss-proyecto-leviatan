extends VBoxContainer

func play_fade() -> void:
	var tween = get_tree().create_tween()
	for label in self.get_children():
		if label is Label:
			label.visible = true
			label.modulate.a = 0.0
			tween.tween_property(label, "modulate:a", 1.0, 2.0).set_delay(0.5)

func play_fade_out() -> Signal: 
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	return tween.finished
