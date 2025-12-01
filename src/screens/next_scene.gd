extends Button

func play_fade_out() -> Signal: 
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	return tween.finished
