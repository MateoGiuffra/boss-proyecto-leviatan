class_name EnemyIdleState extends State

@onready var enemy: Enemy = $"../.."

func get_input() -> void:
	pass
	
func enter() -> void:
	enemy.movement_direction = 0

func exit() -> void:
	enemy.movement_direction = 0

func update(_delta: float) -> void:
	if enemy.player_target != null:
		enemy.makepath()
		Transitioned.emit(self, "EnemyAttackState")
		
func physics_update(_delta: float) -> void:
	if not enemy.is_on_floor():
		enemy.velocity.y += enemy.gravity * _delta
	else:
		enemy.velocity.x = move_toward(enemy.velocity.x, 0, enemy.friction_weight * enemy.acceleration * _delta)
	
	if enemy.is_on_floor():
		enemy.jumps_left = enemy.max_jumps
