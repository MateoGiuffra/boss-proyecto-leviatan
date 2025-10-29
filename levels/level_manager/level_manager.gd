# LevelManager.gd
extends Node
class_name LevelManager

# Variables inicializadas cuando el nodo LevelManager entra en el árbol de escenas
@onready var level_selector: LevelSelector = $CanvasLayer/LevelSelector

# Variables de estado y recursos
var current_level: Node = null # Almacenará la instancia del nivel activo
@export var player_scene: PackedScene # Escena del jugador
@export var level_scenes: Dictionary = {} # Diccionario para almacenar los niveles a cargar
@export var player: Player
# La línea 'static var _instance: LevelManager = null' no es necesaria si usas Autoload.
# La línea '@export var levels_resource_group: ResourceGroup' se reemplaza por 'level_scenes' (un Dict de PackedScene).

# --- Funciones Esenciales ---

func _ready():
	# Asegúrate de que el LevelSelector esté configurado para manejar transiciones.
	# Conectando la señal de LevelSelector si tiene una
	if is_instance_valid(level_selector) and level_selector.has_signal("level_selected"):
		level_selector.level_selected.connect(load_level)
	
	# Ejemplo de cómo cargar todos los niveles automáticamente (Opcional)
	# Aquí cargarías en el diccionario 'level_scenes' todas tus PackedScenes.
	pass

func load_level(level_name: String):
	# 1. Eliminar el nivel anterior si existe
	if is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null
		
	# 2. Cargar la escena del nuevo nivel
	if level_scenes.has(level_name):
		var level_scene: PackedScene = level_scenes[level_name]
		var new_level: Node = level_scene.instantiate()
		
		# 3. Añadir el nuevo nivel al árbol de escenas como hijo del LevelManager
		add_child(new_level)
		current_level = new_level
		
		# 4. Instanciar y colocar al jugador (si el LevelManager lo gestiona)
		if is_instance_valid(player_scene):
			var new_player = player_scene.instantiate()
			# Asume que el nivel tiene un nodo de tipo Marker2D llamado 'SpawnPoint'
			var spawn_point = new_level.find_child("SpawnPoint")
			if spawn_point:
				new_player.global_position = spawn_point.global_position
			
			new_level.add_child(new_player)
			# Actualiza la referencia del jugador que se exportó en el manager (línea 8 del ejemplo)
			player = new_player
	else:
		print("ERROR: El nivel '%s' no está registrado en LevelManager." % level_name)
