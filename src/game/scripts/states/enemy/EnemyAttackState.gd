class_name EnemyAttackState extends State
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"

@onready var enemy: Enemy = $"../.."

func get_input():
	pass

func enter() -> void:
	enemy.movement_direction = 0
	enemy.makepath()
	audio_stream_player_2d.play()

func exit() -> void:
	enemy.movement_direction = 0

func physics_update(delta: float) -> void:
	if not enemy.is_on_floor():
		enemy.velocity.y += enemy.gravity * delta
	else:
		enemy.jumps_left = enemy.max_jumps
	
	enemy.navigate(delta)
	
func update(_delta: float) -> void:
	if !enemy.can_follow():
		Transitioned.emit(self, "EnemyIdleState")
