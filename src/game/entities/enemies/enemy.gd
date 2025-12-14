extends CharacterBody2D
class_name Enemy

@onready var animated_enemy_2d: AnimatedSprite2D = $AnimatedEnemy2D
@onready var damage_timer: Timer = $Timers/DamageTimer
@onready var ray_cast_2d: RayCast2D = $RayCast2D

@onready var collision_area: Area2D = $CollisionArea 
@export var guaranteed_attack_distance: float = 14.0  

var on_ceiling = false
@export var movement_speed: float = 150.0
@export var friction_weight: float = 6.25
@export var gravity: float = 725.0
@export var stop_distance_from_player: float = 8.0

@export var knockback_speed: float = 420.0
@export var knockback_jump_speed: float = 200.0
@export var knockback_duration: float = 0.12
@export var knockback_friction: float = 3000.0

var is_knocked_back = false
var knockback_time_left: float = 0.0

@export var min_dir_change_distance: float = 8.0
@export var dir_change_cooldown: float = 0.2
var can_change_direction = true
var dir_change_cooldown_left: float = 0.0

var movement_direction: int = 0
var facing_direction: int = 1
var player_target: Player = null

@export var min_view_distance_when_close: float = 120.0
@export var ray_vertical_offset: float = -40.0
@export var close_speed_factor: float = 0.1


func _ready() -> void:
	ray_cast_2d.enabled = true
	ray_cast_2d.exclude_parent = true


func _physics_process(delta: float) -> void:
	if not can_change_direction:
		dir_change_cooldown_left -= delta
		if dir_change_cooldown_left <= 0.0:
			can_change_direction = true

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_knocked_back:
		velocity.x = move_toward(velocity.x, 0.0, knockback_friction * delta)
		knockback_time_left -= delta
		if knockback_time_left <= 0.0:
			is_knocked_back = false
	else:
		if player_target != null and _ray_sees_player():
			_follow_player(delta)
		else:
			_idle(delta)

	# Opción A: si está pegado o solapando y por algún motivo no entró el evento, igual ataca con cooldown
	_try_attack_if_stuck_close()

	_update_animation()
	move_and_slide()


func _ray_sees_player() -> bool:
	if player_target == null:
		return false

	var target_global = player_target.global_position + Vector2(0.0, ray_vertical_offset)
	var local_target = ray_cast_2d.to_local(target_global)
	ray_cast_2d.target_position = local_target
	ray_cast_2d.force_raycast_update()

	if not ray_cast_2d.is_colliding():
		return false

	var collider = ray_cast_2d.get_collider()
	return collider == player_target


func _follow_player(delta: float) -> void:
	var dx = player_target.global_position.x - global_position.x
	var abs_dx = abs(dx)

	if abs_dx < min_dir_change_distance:
		velocity.x = move_toward(velocity.x, 0.0, friction_weight * movement_speed * delta)
		return

	var new_dir = sign(dx)

	if new_dir != 0 and new_dir != movement_direction and can_change_direction:
		movement_direction = int(new_dir)
		facing_direction = movement_direction
		can_change_direction = false
		dir_change_cooldown_left = dir_change_cooldown

	velocity.x = movement_direction * movement_speed


func _idle(delta: float) -> void:
	movement_direction = 0
	velocity.x = move_toward(velocity.x, 0.0, friction_weight * movement_speed * delta)


func _update_animation() -> void:
	if velocity.y < 0:
		animated_enemy_2d.play("jump")
	elif movement_direction != 0:
		animated_enemy_2d.play("walk")
	else:
		animated_enemy_2d.play("idle")

	animated_enemy_2d.flip_h = facing_direction < 0


func _try_attack_if_stuck_close() -> void:
	if player_target == null:
		return

	# si el cooldown (timer) está corriendo, no atacamos
	if not damage_timer.is_stopped():
		return

	# 1) distancia mínima: caso "pegado"
	var close_enough := global_position.distance_to(player_target.global_position) <= guaranteed_attack_distance

	# 2) overlap real del Area2D (por si la distancia no alcanza o el shape es raro)
	var overlapping := false
	if collision_area != null:
		overlapping = collision_area.overlaps_body(player_target)

	if close_enough or overlapping:
		player_target.damage_player()
		apply_knockback_from(player_target.global_position)
		damage_timer.start()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_target = body as Player


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_target:
		player_target = null


func _on_collision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_target = body as Player
		if damage_timer.is_stopped():
			player_target.damage_player()
			apply_knockback_from(player_target.global_position)
			damage_timer.start()


func _on_collision_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_target = null
		damage_timer.stop()


func _on_damage_timer_timeout() -> void:
	if player_target != null:
		player_target.damage_player()


func apply_knockback_from(attacker_position: Vector2) -> void:
	var dir = sign(global_position.x - attacker_position.x)
	if dir == 0:
		dir = 1

	is_knocked_back = true
	knockback_time_left = knockback_duration
	velocity.x = dir * knockback_speed
	velocity.y = -knockback_jump_speed


func on_hit_by_player(player: Player) -> void:
	apply_knockback_from(player.global_position)
