class_name Level extends Node

@export var initial_player_position: CollisionShape2D

func start(player: Player) -> void:
	player.global_position = initial_player_position.global_position
