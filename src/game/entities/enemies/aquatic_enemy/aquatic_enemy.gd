extends Area2D
class_name AquaticEnemy

@onready var ray_cast_2d: RayCast2D = $Pivot/RayCast2D
@onready var animated_sprite_2d: AnimatedSprite2D = $Pivot/AnimatedSprite2D
@onready var pivot: Node2D = $Pivot

@export var swim_speed: float = 90.0
@export var contact_damage: int = 1

var _direction: int = 1

func _ready() -> void:
	_direction = 1 if pivot.scale.x >= 0.0 else -1
	ray_cast_2d.enabled = true
	play_animation("swim")

func play_animation(animation_name: String) -> void: 
	if animated_sprite_2d.sprite_frames.has_animation(animation_name):
		animated_sprite_2d.play(animation_name)

func has_turn_around() -> bool:
	if ray_cast_2d.is_colliding():
		var collider: Object = ray_cast_2d.get_collider()
		return not collider.is_in_group("Player")
	return false 

func _physics_process(delta: float) -> void:
	var move_delta := Vector2(swim_speed * _direction, 0.0) * delta
	global_position += move_delta

	if has_turn_around():
		_turn_around()

func _turn_around() -> void:
	_direction *= -1
	pivot.scale.x = _direction

func _on_body_entered(body: Node2D) -> void:
	body.damage_player(contact_damage, true)
