class_name GameLevel extends Node

@export var initial_player_position: CollisionShape2D

func start(player: Player) -> void:
	player.activate()
	player.global_position = initial_player_position.global_position

signal return_requested()
# Reinicia el nivel
signal restart_requested()
# Inicia el siguiente nivel
signal next_level_requested()


func _ready() -> void:
	randomize()
	

# Funciones que hacen de interfaz para las señales
func _on_level_won() -> void:
	next_level_requested.emit()


func _on_return_requested() -> void:
	return_requested.emit()


func on_level_won() -> void:
	next_level_requested.emit()


func on_return_requested() -> void:
	return_requested.emit()


func _on_defeat_menu_retry_selected() -> void:
	next_level_requested.emit()


func _on_defeat_menu_return_selected() -> void:
	return_requested.emit()
