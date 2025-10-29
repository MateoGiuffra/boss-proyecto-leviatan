class_name EnemyIdleState extends State

@export var enemy: CharacterBody2D

func get_input() -> void:
	pass
	
func enter() -> void:
	print("state changed to EnemyIdleState")
	enemy.movement_direction = 0 

func exit() -> void:
	enemy.movement_direction = 0

func update(_delta: float) -> void:
	if enemy && enemy.can_follow():
		Transitioned.emit(self, "EnemyAttackState")
		
func physics_update(_delta: float) -> void:
	enemy.velocity.x = move_toward(enemy.velocity.x, 0, enemy.movement_speed_limit * enemy.friction_weight * _delta)
