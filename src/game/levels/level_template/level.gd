class_name GameLevel extends Node

@export var initial_player_position: CollisionShape2D
var lights: Array[Light2D] = []
@export var enable_distance := 600

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
	for light in get_tree().get_nodes_in_group("dynamic_light"):
		if light is Light2D:
			light.enabled = false
			lights.append(light)
	print("size: " + str(lights.size()))
	print("2size: " + str(get_tree().get_nodes_in_group("dynamic_light").size()))


func _process(_delta: float) -> void:
	if GameState.current_player: 
		var camera := GameState.current_player.camera
		if camera == null:
			return

		var cam_pos := camera.global_position

		for light in lights:
			if light: 
				var dist := cam_pos.distance_to(light.global_position)
				light.enabled = dist <= enable_distance

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
