extends Node

## La escena principal pasa a ser el MainMenu, y lo que era la escena
## Main se refactorizó a Level01 y se lo integró como Nivel dentro
## de LevelManager (Leer más ahí).

## El fondo de la interfaz puede personalizarse a gusto. Puede ser
## una imagen estática, con movimiento, o como se quiera.
## Los nodos de Control que manejan el flujo de la aplicación están
## en CanvasLayer/Container. Si no estuvieran dentro del CanvasLayer,
## se verían afectados por el movimiento de la cámara.

## PISTA: El input del mouse podría no se capturado por default por los
## elementos interactivos. Eso puede ser porque algun otro nodo de Control
## que se dibuja encima está consumiendo ese Input primero.
## Se puede revisar la propiedad Control.mouse_filter en el inspector y en
## la documentación para experimentar

@export var level_manager_scene: PackedScene
@onready var zoom_effect: Control = $Menus/InitMenu/Container
@onready var fade_rect: ColorRect = $Menus/InitMenu/Container/FadeRect
@onready var audio_background_menu: AudioStreamPlayer = $Sound/AudioBackgroundMenu


@export var enable_distance := 1000.0

var lights: Array[Light2D] = []

func _ready() -> void:
	InputMapLoader.load_input_map()
	Input.set_custom_mouse_cursor(load("res://assets/textures/cursor/cursor.png"))

func _on_start_button_pressed() -> void:
	var zoom_amount = 4.5
	var target_point = Vector2(640, 210)
	var screen_center = Vector2(640, 360)
	var extra_offset = Vector2(-250, 200)  
	var new_position = screen_center - (target_point * zoom_amount) + extra_offset

	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	var tween_audio = get_tree().create_tween()
	# ambas llamadas sin delay: deberían ejecutarse en paralelo
	tween1.tween_property(zoom_effect, "scale", Vector2(zoom_amount, zoom_amount), 3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween2.tween_property(zoom_effect, "position", new_position, 3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween3.tween_property(fade_rect, "color:a", 1.0, 1) 
	tween_audio.tween_property(audio_background_menu, "volume_db", -50, 2)

	
	await tween3.finished
	await tween_audio.finished
	await tween1.finished
	await tween2.finished
	
	
	get_tree().change_scene_to_packed(level_manager_scene)
	
func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
	
