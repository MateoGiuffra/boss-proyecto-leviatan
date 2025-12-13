extends TextureRect

func play_fade() -> void:
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	self.visible = true
	self.modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, 4.0).set_delay(1)

func play_fade_out() -> Signal: 
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 0.0, 1)
	return tween.finished
