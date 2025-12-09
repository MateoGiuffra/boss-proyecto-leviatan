class_name GameLevel extends Node

@export var initial_player_position: CollisionShape2D
var lights: Array[Light2D] = []
@export var enable_distance := 600

@onready var player: Player = $Player
@onready var cine_cam: Camera2D = $CineCam
@onready var boss: Area2D = $Boss
var in_cinematic: bool = false

func start(player: Player) -> void:
	player.activate()
	player.global_position = initial_player_position.global_position

signal return_requested()
# Reinicia el nivel
signal restart_requested()
# Inicia el siguiente nivel
signal next_level_requested()
# avisa que se puede ganar el nivel
signal can_win_level() 

func _ready() -> void:
	randomize()
	cine_cam.enabled = true
	
func _process(delta: float) -> void:
	if player and not in_cinematic: 
		cine_cam.global_position = player.global_position
	
# Funciones que hacen de interfaz para las señales
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
	
func _on_can_win_level() -> void: 
	print("me llamaron _on_can_win_level")
	start_boss_intro()
	
func cinematic_move(camera: Camera2D, from: Vector2, to: Vector2, duration: float = 2.0, pause: float = 1.5) -> void:
	# Posicionamos la cámara en el punto inicial
	camera.global_position = from

	# TWEEN: ida (from → to)
	var tween_forward := get_tree().create_tween()
	tween_forward.tween_property(
		camera,
		"global_position",
		to,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween_forward.finished

	# Pausa dramática
	if pause > 0:
		await get_tree().create_timer(pause).timeout

	# TWEEN: vuelta (to → from)
	var tween_back := get_tree().create_tween()
	tween_back.tween_property(
		camera,
		"global_position",
		from,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween_back.finished

func start_boss_intro() -> void:
	if in_cinematic:
		return
	in_cinematic = true

	cine_cam.enabled = true
	player.desactivate(false)

	print("start_boss_intro llamado")

	await cinematic_move(
		cine_cam,
		player.global_position,
		boss.global_position,
		2.0,     # duración ida/vuelta
		1.5      # pausa sobre el boss
	)

	cine_cam.enabled = false
	player.activate()
	in_cinematic = false
	boss.init_attack()
	
