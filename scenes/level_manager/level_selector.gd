
extends Control
class_name LevelSelector

# --- Señales ---
# Esta señal se emitirá para decirle al LevelManager qué nivel debe cargar.
signal level_selected(level_name: String)


# --- Variables ---

# Diccionario para mapear botones de UI a los nombres de los niveles.
# Esto debería configurarse en el Inspector.
@export var level_map: Dictionary = {
	"New Game": "Level_01",
	"Tutorial": "Tutorial",
	"Options": "Options"
}


# --- Funciones ---

func _ready():
	# Conectar los botones a una función genérica
	# Esto es solo un ejemplo; debes adaptar los nombres de los nodos.
	
	# Asume que tienes botones con los nombres "Button_World_1" y "Button_Tutorial"
	for button_name in level_map.keys():
		var button = find_child(button_name, true)
		if button and button is Button:
			# Usamos 'Callable' para pasar el nombre del nivel como argumento
			var level_to_load = level_map[button_name]
			button.pressed.connect(Callable(self, "_on_button_pressed").bind(level_to_load))
			
		elif not button:
			print("ADVERTENCIA: No se encontró el botón con nombre único: %s" % button_name)


# Función que se ejecuta al presionar cualquier botón de nivel.
func _on_button_pressed(level_name: String):
	# 1. Ocultar el selector de nivel
	hide()
	
	# 2. EMITIR LA SEÑAL para que el LevelManager cargue el nivel
	# Esta es la conexión clave con el LevelManager.
	print("Señal emitida para cargar el nivel: %s" % level_name)
	level_selected.emit(level_name)


# Función opcional para volver a mostrar el selector (ej: al morir o pausar)
func show_selector():
	show()
