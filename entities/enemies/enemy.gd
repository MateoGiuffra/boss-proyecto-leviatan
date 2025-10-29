extends CharacterBody2D
@onready var animated_enemy_2d: AnimatedSprite2D = $AnimatedEnemy2D
@onready var state_machine: Node = $StateMachine

@export var acceleration: float = 3750.0
@export var movement_speed_limit: float = 300.0
@export var friction_weight: float = 6.25 	
@export var gravity: float = 725.0 
@export var jump_speed: int = 450
@export var follow_distance:float = 200

var movement_direction: int
var player_target: CharacterBody2D = null

func want_moving():
	return movement_direction != 0

func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * _delta
	
	if want_moving():
		_play_animation("walk")
		animated_enemy_2d.flip_h = movement_direction < 0
	else:
		_play_animation("idle")
		
	move_and_slide()
		
func _play_animation(animation_name: StringName) -> void: 
	if animated_enemy_2d.sprite_frames.has_animation(animation_name):
		animated_enemy_2d.play(animation_name)
	else: 
		print("unrecognized animation name " + str(animation_name))

func can_follow() -> bool:
	if player_target == null:
		return false
	
	var distance_to_player = global_position.distance_to(player_target.global_position)

	return player_target != null \
		and player_target.is_on_floor() \
		and distance_to_player <= follow_distance

func _on_detection_area_body_entered(body: Node2D) -> void:
	player_target = body
	state_machine.set_state("EnemyAttackState")
	
func _on_animated_enemy_2d_animation_looped() -> void:
	if animated_enemy_2d.animation == "idle":
		animated_enemy_2d.flip_h = !animated_enemy_2d.flip_h
