class_name PlayerDashState extends State

@export var player: CharacterBody2D
@export var dash_speed: float = 1200.0

func get_input() -> void:
	pass
	
func enter() -> void:
	player.velocity += Vector2(player.movement_direction, 0).normalized() * player.dash_speed
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	if !player.is_dashing: 
		Transitioned.emit(self, "PlayerWalkState")
		
	
func physics_update(_delta: float) -> void:
	pass
