extends Area2D
class_name Ammo

@export var speed: float = 400.0

var direction: Vector2 = Vector2.ZERO

func set_shoot_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	rotation = direction.angle()  # para que la bala “mire” hacia donde va

func _physics_process(delta: float) -> void:
	if direction == Vector2.ZERO:
		return
	
	position += direction * speed * delta
