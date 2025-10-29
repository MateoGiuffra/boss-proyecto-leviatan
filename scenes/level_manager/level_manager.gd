# LevelManager.gd
extends Node2D
class_name LevelManager

# Variables inicializadas cuando el nodo LevelManager entra en el árbol de escenas
@onready var level_selector: LevelSelector = $CanvasLayer/LevelSelector
@export var game_menu_scene: PackedScene
var game_menu: Control = null

# Variables de estado y recursos
var current_level: Node = null # Almacenará la instancia del nivel activo
@export var player_scene: PackedScene # Escena del jugador
@export var level_scenes: Dictionary = {} # Diccionario para almacenar los niveles a cargar
@export var player: Player

func _ready():
	if is_instance_valid(level_selector) and level_selector.has_signal("level_selected"):
		level_selector.level_selected.connect(load_level)
	
	if is_instance_valid(game_menu_scene):
		game_menu = game_menu_scene.instantiate()
		add_child(game_menu)
		game_menu.hide()
	else:
		print("no se encontro papu")

func load_level(level_name: String):
	if is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null
		
	if level_scenes.has(level_name):
		var level_scene: PackedScene = level_scenes[level_name]
		var new_level: Node = level_scene.instantiate()
		add_child(new_level)
		current_level = new_level
		if new_level.has_method("start"):
			new_level.start(player)
	else:
		print("ERROR: El nivel '%s' no está registrado en LevelManager." % level_name)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape") and current_level:
		game_menu.show()
		
func _on_exit_pressed() -> void:
	get_tree().quit()
