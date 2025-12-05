extends CharacterBody2D
class_name Enemy

@onready var animated_enemy_2d: AnimatedSprite2D = $AnimatedEnemy2D
@onready var state_machine: Node = $StateMachine
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
# raycasts: 
@onready var always_up_ray_cast_2d: RayCast2D = $DetectionArea/AlwaysUpRayCast2D
@onready var ray_cast_2d: RayCast2D = $DetectionArea/RayCast2D
# timers
@onready var damage_timer: Timer = $Timers/DamageTimer


#movements
var on_ceiling := false
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

func _ready() -> void:
	ray_cast_2d.enabled = true
	if player_target:
		makepath()

func _physics_process(_delta: float) -> void:
	update_orientation()
	if want_moving():
		_play_animation("walk")
		animated_enemy_2d.flip_h = movement_direction < 0
	else:
		_play_animation("idle")
	
	aim_to_player()
	move_and_slide()

func update_orientation() -> void:
	var colliding_ceiling := is_colliding_up()
	
	if colliding_ceiling and not on_ceiling:
		on_ceiling = true
		# Opción A: flip vertical
		animated_enemy_2d.flip_v = true
		# Si preferís rotación en vez de flip:
		# animated_enemy_2d.rotation_degrees = 180
		
	elif not colliding_ceiling and on_ceiling:
		on_ceiling = false
		animated_enemy_2d.flip_v = false
		# animated_enemy_2d.rotation_degrees = 0

	
func is_colliding_up() -> bool: 
	return always_up_ray_cast_2d.is_colliding()	

func want_moving():
	return movement_direction != 0
	
func _on_timer_make_path_timeout() -> void:
	makepath()

func makepath() -> void:
	if player_target:
		nav_agent.target_position = player_target.global_position

func navigate(delta):
	if nav_agent.is_navigation_finished():
		movement_direction = 0
		velocity.x = lerp(velocity.x, 0.0, delta * 8.0)
		return
		
	var next_path_point = nav_agent.get_next_path_position()
	var dir = (next_path_point - global_position).normalized()
	
	# Movimiento horizontal solamente
	velocity.x = dir.x * movement_speed_limit
	
	# Movimiento vertical → dejarlo a la física
	if not is_on_floor():
		velocity.y += gravity * delta


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

	
func _on_collision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_target = body 
		
		# Aplica el primer tick de daño y ENCIENDE el Timer
		if damage_timer.is_stopped():
			player_target.beaten()
			GameState.current_player_changed.emit()
			damage_timer.start()

# NUEVA FUNCIÓN NECESARIA: Detiene el daño recurrente
func _on_collision_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# ¡IMPORTANTE! Detiene el contador de daño cuando el jugador se va
		damage_timer.stop()
		player_target = null # Opcional: limpiar la referencia

# La función del Timer se mantiene simple, ya que el Timer solo corre cuando el jugador está dentro
func _on_damage_timer_timeout() -> void:
	# Verificamos si la referencia al jugador todavía existe
	if player_target:
		player_target.beaten()
		GameState.current_player_changed.emit()
