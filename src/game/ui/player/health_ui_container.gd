extends HBoxContainer
class_name HealthUI

@export var hp_per_heart: float = 1.0
@export var heart_scene: PackedScene

var hearts: Array[HeartIcon] = []

func set_health(current_hp: float, max_hp: float, flash_on_change: bool = false) -> void:
	# Cuántos corazones necesito
	var hearts_needed := int(ceil(max_hp / hp_per_heart))

	# Asegurar cantidad de corazones
	while hearts.size() < hearts_needed:
		var h: HeartIcon = heart_scene.instantiate()
		add_child(h)
		hearts.append(h)

	while hearts.size() > hearts_needed:
		var h = hearts.pop_back()
		h.queue_free()

	# Actualizar estado de cada corazón
	for i in range(hearts_needed):
		var remaining := current_hp - float(i) * hp_per_heart
		var desired_state: HeartIcon.State

		if remaining >= hp_per_heart:
			desired_state = HeartIcon.State.FULL
		elif remaining > 0.0:
			desired_state = HeartIcon.State.HALF
		else:
			desired_state = HeartIcon.State.EMPTY

		var heart := hearts[i]
		var changed = heart.state != desired_state
		heart.set_state(desired_state)

		if flash_on_change and changed:
			heart.flash_outline()
