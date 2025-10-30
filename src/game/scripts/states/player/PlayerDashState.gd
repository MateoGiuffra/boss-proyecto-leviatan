class_name PlayerDashState extends State

@export var player: CharacterBody2D
@export var dash_speed: float = 1200.0
@onready var dash_cold_down: Timer = $"../../Timers/DashColdDown"
@onready var step_sound: AudioStreamPlayer2D = $"../../Sounds/StepSound"
@onready var wash_sound: AudioStreamPlayer2D = $"../../Sounds/WashSound"

func get_input() -> void:
	pass
	
func enter() -> void:
	player.finish_colddown_dash = false
	player.velocity += Vector2(player.movement_direction, 0).normalized() * player.dash_speed
	dash_cold_down.start()
	wash_sound.play()
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	if !player.is_dashing: 
		Transitioned.emit(self, "PlayerWalkState")
		
	
func physics_update(_delta: float) -> void:
	pass
