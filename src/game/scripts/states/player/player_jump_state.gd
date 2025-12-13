class_name PlayerJumpState extends State


@onready var swim_boost_cold_down: Timer = $"../../Timers/SwimBoostColdDown"

@export var player: Player
@onready var step_sound: AudioStreamPlayer = $"../../Sounds/StepSound"
@onready var jump_sound: AudioStreamPlayer = $"../../Sounds/JumpSound"

var air_movement_direction: int

	
# --- Funciones de efectos ---
func _effect_1() -> void:
	# Subir un poco el pitch, bajar volumen
	jump_sound.pitch_scale = 1.1
	jump_sound.volume_db = -3

func _effect_2() -> void:
	# Bajar pitch, subir volumen
	jump_sound.pitch_scale = 0.9
	jump_sound.volume_db = 0

func _effect_3() -> void:
	# Pitch normal, volumen random
	jump_sound.pitch_scale = 1.0
	jump_sound.volume_db = randf_range(-2, 2)

# --- Función para randomizar efectos ---
func _play_jump_with_random_effect() -> void:
	var effects = [_effect_1, _effect_2, _effect_3]
	var effect_to_apply = effects[randi() % effects.size()]
	effect_to_apply.call()
	jump_sound.play()

# --- Entrada al estado ---
func enter() -> void:
	player.finish_colddown_swim_boost = false
	player.velocity.y -= player.jump_speed
	swim_boost_cold_down.start()
	player.emit_particles(-90)
	_play_jump_with_random_effect()
	player.set_oxygen_bar_moving_position()
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	get_input()
	
	player.velocity.y += player.gravity * _delta
	
	if player: 
		if player.want_moving():
			player.move_player(_delta)
		else: 
			player.stop_player(_delta)
	
	if player.can_use_swim_boost(): 
		player.finish_colddown_swim_boost = false
		swim_boost_cold_down.start()
		player.velocity.y -= player.jump_speed
		player.count_swim_boost -= 1
	
	player.move_and_slide()
	
	if player.is_on_floor() and player.velocity.y >= 0:
		player.count_swim_boost = player.swim_boost
		Transitioned.emit(self, "PlayerWalkState")
	
	if player.is_dashing: 
		Transitioned.emit(self, "PlayerDashState")	

func get_input() -> void:
	pass
	

	
