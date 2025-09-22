extends CharacterBody2D

@export var ACCELERATION: float = 3750.0 
@export var H_SPEED_LIMIT: float = 600.0
@export var jump_speed: int = 500
@export var FRICTION_WEIGHT: float = 6.25 
@export var gravity: int = 625.0 

var h_movement_direction: int = 0
var jump: bool = false

func _physics_process(delta: float) -> void:
	get_input()
	
	# Apply velocity
	if h_movement_direction != 0:
		velocity.x = clamp(
			velocity.x + (h_movement_direction * ACCELERATION * delta),
			-H_SPEED_LIMIT,
			H_SPEED_LIMIT
		)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION_WEIGHT * delta) if abs(velocity.x) > 1 else 0
	
	# Jump
	if jump and is_on_floor():
		velocity.y -= jump_speed
	
	# Gravity
	velocity.y += gravity * delta
	
	move_and_slide()

func get_input() -> void:
	# Jump Action
	jump = Input.is_action_just_pressed("jump")

	#horizontal speed
	h_movement_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
