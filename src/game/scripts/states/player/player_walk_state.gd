class_name PlayerWalkState
extends State

@export var player: CharacterBody2D

@onready var double_tap_timer: Timer = $"../../Timers/DoubleTapTimer"
@onready var dash_timer: Timer = $"../../Timers/DashTimer"
@onready var step_sound: AudioStreamPlayer = $"../../Sounds/StepSound"
@onready var animated_player: AnimatedSprite2D = $"../../Pivot/AnimatedPlayer"

# Lista de sonidos posibles (asignar en el editor)
@export var step_sounds: Array[AudioStream] = []

# Frames donde el pie toca el suelo
var step_frames := [1, 5, 7, 10]
var last_frame_played := -1

# Control interno para evitar múltiples colas de sonidos
var _waiting_to_play := false

func enter() -> void:
	player.movement_direction = 0
	player.jump = false
	player.is_dashing = false
	player.waiting_second_tap = false
	_waiting_to_play = false
	player.set_oxygen_bar_moving_position()

	if not animated_player.is_connected("frame_changed", Callable(self, "_on_frame_changed")):
		animated_player.connect("frame_changed", Callable(self, "_on_frame_changed"))

func exit() -> void:
	if animated_player.is_connected("frame_changed", Callable(self, "_on_frame_changed")):
		animated_player.disconnect("frame_changed", Callable(self, "_on_frame_changed"))

	last_frame_played = -1
	_waiting_to_play = false
	step_sound.stop()

func physics_update(_delta: float) -> void:
	get_input()
	player.velocity.y += player.gravity * _delta

	if player:
		if player.want_moving():
			player.move_player(_delta)
		else:
			player.stop_player(_delta)

	if player.jump:
		Transitioned.emit(self, "PlayerJumpState")

	if player.is_dashing:
		Transitioned.emit(self, "PlayerDashState")

func update(_delta: float) -> void:
	pass

func get_input() -> void:
	pass

# --- SONIDO DE PISADAS ---
func _on_frame_changed() -> void:
	if animated_player.animation == "walk" and player.is_on_floor():
		var current_frame := animated_player.frame

		if current_frame != last_frame_played and current_frame in step_frames:
			_play_step_sound_safely()

		last_frame_played = current_frame


func _play_step_sound_safely() -> void:
	# Si ya se está reproduciendo o esperando, no hacemos nada
	if step_sound.playing or _waiting_to_play:
		return

	# Elegimos un sonido aleatorio si hay varios disponibles
	play_random_sound(step_sounds, step_sound)

	# Si el personaje sigue caminando y el sonido aún no terminó,
	# esperamos su final para permitir el siguiente paso
	_waiting_to_play = true
	await step_sound.finished
	_waiting_to_play = false
