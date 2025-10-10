class_name PlayerWalkState extends State

@export var acceleration: float = 3750.0
@export var movement_speed_limit: float = 300.0
@export var friction_weight: float = 6.25 	
@export var player: CharacterBody2D


var movement_direction: int
var jump: bool

func enter() -> void: 
	movement_direction = 0
	jump = false

func exit() -> void:
	pass
	
func physics_update(_delta: float) -> void:
	get_input()
	
	if player: 
		if _want_moving():
			_move_player(_delta)
		else: 
			_stop_player(_delta)
	
	if jump: 
		Transitioned.emit(self, "PlayerJumpState")
	
		
func update(_delta: float) -> void:
	pass

func get_input() -> void:
	movement_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))	
	jump = Input.is_action_just_pressed("jump")

func _want_moving() -> bool: 
	return movement_direction != 0
	
func _move_player(_delta: float):
	var current_movement_speed = player.velocity.x + (movement_direction * acceleration * _delta)
	player.velocity.x = clamp(current_movement_speed, -movement_speed_limit, movement_speed_limit)
	
func _stop_player(_delta: float):  
	player.velocity.x = lerp(player.velocity.x, 0.0, friction_weight * _delta) if abs(player.velocity.x) > 1 else 0
