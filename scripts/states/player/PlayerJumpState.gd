class_name PlayerJumpState extends State

@export var gravity: float = 725.0 
@export var jump_speed: int = 450
@export var air_acceleration: float = 3750.0
@export var air_speed_limit: float = 300.0
@export var air_friction_weight: float = 6.25 	

@export var player: CharacterBody2D

var air_movement_direction: int

	
func enter() -> void:
	air_movement_direction = 0
	player.velocity.y -= jump_speed
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	get_input()
	
	player.velocity.y += gravity * _delta
	
	if player: 
		if _want_moving():
			_move_player(_delta)
		else: 
			_stop_player(_delta)
	
	player.move_and_slide()
	
	if player.is_on_floor() and player.velocity.y >= 0:
		Transitioned.emit(self, "PlayerWalkState")

func get_input() -> void:
	air_movement_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))	
	
func _want_moving() -> bool: 
	return air_movement_direction != 0
	
func _move_player(_delta: float):
	var current_movement_speed = player.velocity.x + (air_movement_direction * air_acceleration * _delta)
	player.velocity.x = clamp(current_movement_speed, -air_speed_limit, air_speed_limit)
	
func _stop_player(_delta: float):  
	player.velocity.x = lerp(player.velocity.x, 0.0, air_friction_weight * _delta) if abs(player.velocity.x) > 1 else 0
