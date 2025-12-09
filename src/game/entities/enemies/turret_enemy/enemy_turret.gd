extends Area2D
class_name EnemyTurret
@onready var origin_zone: CollisionShape2D = $OriginZone
@onready var shoot_timer: Timer = $ShootTimer
@onready var pivot: Area2D = $Pivot
@onready var ray_cast_2d: RayCast2D = $Pivot/RayCast2D
@onready var animated_sprite: AnimatedSprite2D = $Pivot/AnimatedSprite2D

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
	animated_sprite.play("idle")
	if target_player: 
		aim_to_player()

func _play_animation(animation_name: StringName)-> void:
	if animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)

func aim_to_player() -> void: 
	var target_global = target_player.global_position + Vector2(0.0, ray_vertical_offset)
	ray_cast_2d.target_position = to_local(target_global)
	if can_shoot():
		shoot()
		_play_animation("shoot")
		
func can_shoot() -> bool:
	if ray_cast_2d.is_colliding():
		var collider: Object = ray_cast_2d.get_collider()
		return target_player and collider == target_player and not is_shooting
	return false 

func shoot() -> void: 
	if not projectile_scene:
		return 
	var projectile_instance = projectile_scene.instantiate()
	get_parent().add_child(projectile_instance)
	projectile_instance.position = origin_zone.position
		
	var collision_point = ray_cast_2d.get_collision_point()
	var shoot_direction = (collision_point - projectile_instance.position).normalized()
	projectile_instance.set_shoot_direction(shoot_direction)
	is_shooting = true
	shoot_timer.start()

func _on_body_entered(body: Node2D) -> void:
	print("player detectadoo")
	target_player = body as Player

func _on_body_exited(_body: Node2D) -> void:
	target_player = null

func _on_shoot_timer_timeout() -> void:
	is_shooting = false


func _on_animated_sprite_animation_finished() -> void:
	match animated_sprite.animation: 
		"shoot": 
			if target_player: 
				shoot()
		
