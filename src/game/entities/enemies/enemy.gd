extends CharacterBody2D
class_name Enemy

@onready var animated_enemy_2d: AnimatedSprite2D = $AnimatedEnemy2D
@onready var always_up_ray_cast_2d: RayCast2D = $AlwaysUpRayCast2D
@onready var damage_timer: Timer = $Timers/DamageTimer
@onready var ray_cast_2d: RayCast2D = $RayCast2D

# Movimiento
var on_ceiling := false
@export var movement_speed: float = 150.0
@export var friction_weight: float = 6.25
@export var gravity: float = 725.0
@export var stop_distance_from_player: float = 8.0

var movement_direction: int = 0
var player_target: Player = null

func _ready() -> void:
	ray_cast_2d.enabled = true
	ray_cast_2d.exclude_parent = true   # que no se pegue a sí mismo


func _physics_process(delta: float) -> void:
	update_orientation()

	# gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	if player_target and _ray_sees_player():
		_follow_player(delta)
	else:
		_idle(delta)

	_update_animation()
	move_and_slide()


# --- techo ---
func update_orientation() -> void:
	var col := always_up_ray_cast_2d.is_colliding()
	if col and not on_ceiling:
		on_ceiling = true
		animated_enemy_2d.flip_v = true
	elif not col and on_ceiling:
		on_ceiling = false
		animated_enemy_2d.flip_v = false


# --- visión con RayCast ---
@export var min_view_distance_when_close: float = 120.0

@export var ray_vertical_offset: float = -20.0  # -Y = hacia arriba en Godot

func _ray_sees_player() -> bool:
	if player_target == null:
		return false

	# Posición global del "pecho" del player
	var target_global := player_target.global_position + Vector2(0.0, ray_vertical_offset)

	# Convertimos ese punto al espacio local del RayCast2D
	var local_target := ray_cast_2d.to_local(target_global)
	ray_cast_2d.target_position = local_target
	ray_cast_2d.force_raycast_update()

	if not ray_cast_2d.is_colliding():
		return false

	var collider := ray_cast_2d.get_collider()
	return collider == player_target




@export var close_speed_factor: float = 0.1  # 10% de la velocidad normal


# --- seguir al player sin pathfinding ---
func _follow_player(delta: float) -> void:
	# diferencia en X con el player
	var dx := player_target.global_position.x - global_position.x
	var dist_x = abs(dx)
	var dir_x = sign(dx)

	# Siempre está "en modo seguir" mientras te vea
	movement_direction = int(dir_x)
	velocity.x = dir_x * movement_speed



# --- idle ---
func _idle(delta: float) -> void:
	movement_direction = 0
	velocity.x = move_toward(velocity.x, 0.0, friction_weight * movement_speed * delta)


# --- animaciones ---
func _update_animation() -> void:
	if movement_direction != 0:
		animated_enemy_2d.play("walk")
	else:
		animated_enemy_2d.play("idle")

	animated_enemy_2d.flip_h = movement_direction < 0

func _on_animated_enemy_2d_animation_looped() -> void:
	if animated_enemy_2d.animation == "idle":
		animated_enemy_2d.flip_h = !animated_enemy_2d.flip_h


# --- rango (DetectionArea) ---
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_target = body as Player

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_target:
		player_target = null


# --- daño ---
func _on_collision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_target = body as Player
		if damage_timer.is_stopped():
			player_target.beaten()
			damage_timer.start()

func _on_collision_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_target = null
		damage_timer.stop()

func _on_damage_timer_timeout() -> void:
	if player_target:
		player_target.beaten()
