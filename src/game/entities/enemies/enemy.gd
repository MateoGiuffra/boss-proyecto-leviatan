extends CharacterBody2D
@onready var animated_enemy_2d: AnimatedSprite2D = $AnimatedEnemy2D
@onready var state_machine: Node = $StateMachine
@onready var ray_cast_2d: RayCast2D = $DetectionArea/RayCast2D

@export var acceleration: float = 3750.0
@export var movement_speed_limit: float = 300.0
@export var friction_weight: float = 6.25 	
@export var gravity: float = 725.0
@export var jump_speed: int = 450
@export var follow_distance:float = 200

var movement_direction: int
var player_target: Player = null

func want_moving():
	return movement_direction != 0

func _ready() -> void:
	ray_cast_2d.enabled = true
	
	
func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * _delta
	
	if want_moving():
		_play_animation("walk")
		animated_enemy_2d.flip_h = movement_direction < 0
	else:
		_play_animation("idle")
	
	
	move_and_slide()
		
func aim_to_player():
	if player_target:
		var vector_to_player = player_target.global_position - global_position
		var player_position_local_to_raycast = ray_cast_2d.to_local(player_target.global_position)
		ray_cast_2d.target_position = player_position_local_to_raycast

func attack(delta, direction_to_player) -> void:
	movement_direction = sign(direction_to_player.x)
	velocity.x = move_toward(velocity.x, movement_direction * movement_speed_limit, acceleration * delta)

func _play_animation(animation_name: StringName) -> void:
	if animated_enemy_2d.sprite_frames.has_animation(animation_name):
		animated_enemy_2d.play(animation_name)
	else:
		print("unrecognized animation name " + str(animation_name))

func can_follow() -> bool:
	if player_target == null:
		return false
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		return collider == player_target
	return true

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		player_target = body
		state_machine.on_child_transition(state_machine.current_state, "EnemyAttackState")
	
func _on_animated_enemy_2d_animation_looped() -> void:
	if animated_enemy_2d.animation == "idle":
		animated_enemy_2d.flip_h = !animated_enemy_2d.flip_h


func _on_collision_area_body_entered(_body: Node2D) -> void:
	print("te mate wacho")
	player_target.die()
	GameState.current_player_changed.emit()

	
