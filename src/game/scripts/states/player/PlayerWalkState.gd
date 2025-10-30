class_name PlayerWalkState extends State

@export var player: CharacterBody2D

@onready var double_tap_timer: Timer = $"../../Timers/DoubleTapTimer"
@onready var dash_timer: Timer = $"../../Timers/DashTimer"

func enter() -> void: 
	player.movement_direction = 0
	player.jump = false
	player.is_dashing = false
	player.waiting_second_tap = false

func exit() -> void:
	pass
	
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
