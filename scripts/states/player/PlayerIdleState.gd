class_name PlayerIdleState extends State

@onready var animated_player: AnimatedSprite2D = $AnimatedPlayer
@onready var player: CharacterBody2D = $Player

var movement_direction: int

func enter() -> void: 
	movement_direction = 0

func exit() -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func update(_delta: float) -> void:
	get_input()
	if player && movement_direction != 0:
		Transitioned.emit(self, "PlayerWalkState")
	
func get_input() -> void:
	movement_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	print(movement_direction)
