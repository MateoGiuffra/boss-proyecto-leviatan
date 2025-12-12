extends Area2D
class_name EnemyTurret
@onready var shoot_timer: Timer = $ShootTimer
@onready var pivot: Area2D = $Pivot
@onready var animated_sprite: AnimatedSprite2D = $Pivot/AnimatedSprite2D
@onready var origin_zone: CollisionShape2D = $Pivot/OriginZone
@onready var ray_cast_2d: RayCast2D = $Pivot/OriginZone/RayCast2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var ray_vertical_offset: float = -40.0
var target_player: Player

# flags
var is_shooting: bool = false
# exports
@export var projectile_scene: PackedScene
@export var flip: bool = false

func _ready() -> void: 
	pivot.scale.x = -1 if flip else 1


func _physics_process(_delta: float) -> void:
	if target_player:
		aim_to_player()
	else:
		if is_shooting: 
			_play_animation("shoot")
		else:
			_play_animation("idle")

func _play_animation(animation_name: StringName)-> void:
	if animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)

func aim_to_player() -> void: 
	var target_global = target_player.global_position + Vector2(0.0, ray_vertical_offset)
	ray_cast_2d.target_position = ray_cast_2d.to_local(target_global)
	if can_shoot():
		is_shooting = true
		shoot()
		
func can_shoot() -> bool:
	if ray_cast_2d.is_colliding():
		var collider: Object = ray_cast_2d.get_collider()
		return target_player and collider == target_player and not is_shooting
	return false 

func shoot() -> void: 
	if not projectile_scene:
		return
	audio_stream_player_2d.play()
	var projectile_instance = projectile_scene.instantiate()
	get_parent().add_child(projectile_instance)
	projectile_instance.global_position = origin_zone.global_position
	var collision_point = ray_cast_2d.get_collision_point()
	var shoot_direction = (collision_point - projectile_instance.global_position).normalized()
	projectile_instance.set_shoot_direction(shoot_direction)
	shoot_timer.start()
	is_shooting = true

func _on_body_entered(body: Node2D) -> void:
	target_player = body as Player

func _on_body_exited(_body: Node2D) -> void:
	target_player = null

func _on_shoot_timer_timeout() -> void:
	is_shooting = false

func _on_personal_area_2d_body_entered(body: Player) -> void:
	body.damage_player(1, true)
