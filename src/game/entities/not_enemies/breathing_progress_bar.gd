extends ProgressBar
class_name BreathingProgressBar

func set_initial_values(min:float, max:float, initial:float) -> void:
	self.max_value = max
	self.min_value = min
	self.value = initial


func add_breathing(new_breathing, _player: Player) ->void:
		self.value += new_breathing
