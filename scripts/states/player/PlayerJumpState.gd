class_name PlayerJumpState extends State



@export var player: CharacterBody2D

var air_movement_direction: int

	
func enter() -> void:
	air_movement_direction = 0
	player.velocity.y -= player.jump_speed
	
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
	
	player.move_and_slide()
	
	if player.is_on_floor() and player.velocity.y >= 0:
		Transitioned.emit(self, "PlayerWalkState")
	
	if player.is_dashing: 
		Transitioned.emit(self, "PlayerDashState")	

func get_input() -> void:
	pass
