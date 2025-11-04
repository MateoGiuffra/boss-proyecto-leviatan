class_name PlayerIdleState extends State

@onready var player: CharacterBody2D = $"../.."
@onready var animated_player: AnimatedSprite2D = $"../../AnimatedPlayer"
@onready var step_sound: AudioStreamPlayer2D = $"../../Sounds/StepSound"

var movement_direction: int

func enter() -> void: 
	movement_direction = 0
	step_sound.stop()

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
	#print(movement_direction)
