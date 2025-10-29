class_name EnemyAttackState extends State # Asegúrate de que herede de tu clase base State

@export var enemy: CharacterBody2D

func get_input():
	pass

func enter() -> void:
	print("state changed to EnemyAttackState")
	enemy.movement_direction = 0

func exit() -> void:
	enemy.movement_direction = 0

func physics_update(_delta: float) -> void:
	var player_position = enemy.player_target.global_position
	var enemy_position = enemy.global_position

	var direction_to_player = player_position - enemy_position
	
	enemy.movement_direction = sign(direction_to_player.x)
		
	enemy.velocity.x = move_toward(enemy.velocity.x, enemy.movement_direction * enemy.movement_speed_limit, enemy.acceleration * _delta)

func update(_delta: float) -> void:
	if !enemy.can_follow():
		Transitioned.emit(self, "EnemyIdleState")
