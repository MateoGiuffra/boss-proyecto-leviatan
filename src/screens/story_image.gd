extends TextureRect

func play_fade() -> void:
	var tween = get_tree().create_tween()
	self.visible = true
	self.modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, 4.0).set_delay(1)

func play_fade_out() -> Signal: 
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1)
	return tween.finished
