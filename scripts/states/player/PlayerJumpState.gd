class_name PlayerJumpState extends State


@onready var swim_boost_cold_down: Timer = $"../../Timers/SwimBoostColdDown"

@export var player: CharacterBody2D

var air_movement_direction: int

	
func enter() -> void:
	player.finish_colddown_swim_boost = false
	air_movement_direction = 0
	player.velocity.y -= player.jump_speed
	swim_boost_cold_down.start()
	
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
	

	
