extends Control

func _ready() -> void:
	self.visible = false
	self.modulate.a = 0.0

func play_fade() -> void: 
	self.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1)
