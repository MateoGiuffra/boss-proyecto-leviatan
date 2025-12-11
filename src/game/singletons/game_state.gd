extends Node

## Objeto singleton que maneja estados generales del nivel,
## almacena información entre niveles y ayuda a interconectar
## estados entre nodos y escenas distantes.

## Este patrón tranquilamente podría reemplazarse por alternativas,
## como propagación de señales entre padres, o inyección de
## dependencias, pero pueden crear mucho código repetido o
## generar mucho acople.

## Esto nos permite almacenar las armas que fuimos levantando
## entre los niveles. El primero son las armas con las que
## terminamos el nivel, el segundo son las que fuimos levantando.
var zones_stash: Array[String] = [] 
var zones_id: Array[String] = []

func notify_zone_documented(documentable_zone_scene: DocumentableZone) -> void:
	if !zones_id.has(documentable_zone_scene.id):
		documentable_zone_scene.push_back(documentable_zone_scene)

## Señal y variable de ayuda que permite notificar la existencia
## del jugador actual a cualquiera interesado
signal current_player_changed

var current_player: Player

func set_current_player(player: Player) -> void:
	current_player = player
	current_player_changed.emit(player)

## Señal genérica que avisa del cumplimiento de la condición
## de victoria a todos los interesados.
signal level_won()
signal level_lost()

func notify_level_lost() -> void:
	zones_stash.append_array(zones_id)
	zones_id = []
	level_lost.emit() 

func notify_level_won() -> void:
	zones_stash.append_array(zones_id)
	zones_id = []
	current_player.win()
	level_won.emit()
	
	
