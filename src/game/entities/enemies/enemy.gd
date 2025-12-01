extends CharacterBody2D
class_name Enemy

@onready var animated_enemy_2d: AnimatedSprite2D = $AnimatedEnemy2D
@onready var state_machine: Node = $StateMachine
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var ray_cast_2d: RayCast2D = $DetectionArea/RayCast2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var acceleration: float = 3750.0
@export var movement_speed_limit: float = 300.0
@export var friction_weight: float = 6.25 	
@export var gravity: float = 725.0
@export var jump_speed: int = 450
@export var follow_distance:float = 200
@export var max_jumps: int = 2
var jumps_left: int = max_jumps

var movement_direction: int
var player_target: Player = null

const JUMP_HEIGHT_THRESHOLD: float = -30.0
const JUMP_DIST_THRESHOLD: float = 300.0

func want_moving():
	return movement_direction != 0



func _ready() -> void:
	ray_cast_2d.enabled = true
	if player_target:
		makepath()

	
func _on_timer_make_path_timeout() -> void:
	makepath()

func makepath() -> void:
	if player_target:
		nav_agent.target_position = player_target.global_position

func _physics_process(_delta: float) -> void:
	if want_moving():
		_play_animation("walk")
		animated_enemy_2d.flip_h = movement_direction < 0
	else:
		_play_animation("idle")
	
	move_and_slide()

func navigate(delta) -> void:
	if nav_agent.is_navigation_finished():
		movement_direction = 0
		return
		
	var next_path_point = nav_agent.get_next_path_position()
	var direction_to_next_point = global_position.direction_to(next_path_point)
	
	var height_difference = next_path_point.y - global_position.y
	var horizontal_distance = abs(next_path_point.x - global_position.x)
	
	if height_difference < JUMP_HEIGHT_THRESHOLD and horizontal_distance < JUMP_DIST_THRESHOLD:
		if is_on_floor() and jumps_left > 0:
			velocity.y = -jump_speed
			jumps_left -= 1
	
	movement_direction = sign(direction_to_next_point.x)
	var new_velocity_x = move_toward(velocity.x, direction_to_next_point.x * movement_speed_limit, acceleration * delta)
	velocity.x = new_velocity_x
	
	nav_agent.set_velocity(velocity)

func aim_to_player():
	if player_target:
		var player_position_local_to_raycast = ray_cast_2d.to_local(player_target.global_position)
		ray_cast_2d.target_position = player_position_local_to_raycast

func _play_animation(animation_name: StringName) -> void:
	if animated_enemy_2d.sprite_frames.has_animation(animation_name):
		animated_enemy_2d.play(animation_name)
	else:
		print("unrecognized animation name " + str(animation_name))

func can_follow() -> bool:
	if player_target == null:
		return false
	
	# Usamos la distancia como criterio de 'seguir', ya que quitamos la dependencia del RayCast
	var distance_sq = global_position.distance_squared_to(player_target.global_position)
	var follow_sq = follow_distance * follow_distance
	
	# Si el jugador está demasiado lejos, deja de seguir
	if distance_sq > follow_sq * 2.0:
		return false
	
	return true

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):	
		player_target = body
		makepath()
		state_machine.on_child_transition(state_machine.current_state, "EnemyAttackState")
	
func _on_animated_enemy_2d_animation_looped() -> void:
	if animated_enemy_2d.animation == "idle":
		animated_enemy_2d.flip_h = !animated_enemy_2d.flip_h

func _on_collision_area_body_entered(_body: Node2D) -> void:
	player_target.die()
	GameState.current_player_changed.emit()
