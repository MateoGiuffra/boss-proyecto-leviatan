extends CharacterBody2D
class_name Player

# Parámetros que serán gestionados por el State Machine
@export var acceleration: float = 3750.0
@export var movement_speed_limit: float = 300.0
@export var friction_weight: float = 6.25
@export var dash_speed: float = 1200.0
@export var gravity: float = 725.0
@export var jump_speed: int = 450
@export var swim_boost: int = 3
# salud
@export var max_hp: int = 1
var hp: int = max_hp

@onready var animated_player: AnimatedSprite2D = $AnimatedPlayer
@onready var state_machine = $StateMachine

@onready var inventory: Inventory = $Inventory
@export var inventory_ui: InventoryUI
@export var goal: Area2D

@onready var double_tap_timer: Timer = $Timers/DoubleTapTimer
@onready var dash_timer: Timer = $Timers/DashTimer
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var camera: Camera2D = $Camera
@onready var swimming_sound: AudioStreamPlayer2D = $Sounds/SwimmingSound
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var particles_timer: Timer = $Timers/ParticlesTimer

# signals 
signal hp_changed(current_hp: int, max_hp: int)

# Variables para la lógica del dash y swim boost (si no se mueven al State Machine)
var movement_direction: int
var count_swim_boost = swim_boost
var jump: bool
var is_dashing: bool
var waiting_second_tap: bool
var finish_colddown_dash: bool = true
var finish_colddown_swim_boost: bool = true

func die() -> void:
	var new_parent = get_parent()
	remove_child(camera)
	new_parent.add_child(camera) 
	remove_child(point_light_2d) 
	new_parent.add_child(point_light_2d)
	# --- Lógica de Muerte del Player ---
	hp = 0
	hide()
	queue_free()

func sum_hp(amount: int) -> void:
	hp = clamp(hp + amount, 0, max_hp)
	hp_changed.emit(hp, max_hp)
	print("hp_changed %s %s" % [hp, max_hp])

func _ready():
	if inventory_ui == null:
		var ui_nodes: Array = get_tree().get_nodes_in_group("ui_layer")
		if !ui_nodes.is_empty():
			inventory_ui = ui_nodes.get(0)
				
	if inventory_ui != null:
		goal.initialize(inventory)
		inventory_ui.initialize(inventory)
	particles.emitting = false
	GameState.set_current_player(self)
	
	
func desactivate():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	hide()
	if camera:
		camera.enabled = false

func activate():
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	show()
	if camera:
		camera.enabled = true

func _on_item_detector_area_entered(area: Area2D):
	if area.has_method("get_item_data"):
		var world_item_data: ItemData = area.get_item_data()
		print("¡Detectado! Item: " + world_item_data.id)
		
		if inventory.pick_up_item(world_item_data):
			area.queue_free()
			print("Recogido: ", world_item_data.id)

func is_dead():
	return hp <= 0

func _physics_process(_delta: float) -> void:
	if !is_on_floor() and not swimming_sound.playing:
		swimming_sound.play()
		
	
	if is_dead():
		GameState.level_lost.emit()
	# La lógica de animación y movimiento debe ser gestionada por el State Machine,
	# pero dejo la parte de la gravedad/input aquí para que los estados la utilicen.
	
	get_input()
	
	# La animación ya no se gestiona aquí, sino en los PlayerState.gd
	# El State Machine se encarga del movimiento (move_and_slide())
	move_and_slide()
	
	
func get_input() -> void:
	movement_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))	
	jump = Input.is_action_just_pressed("jump")
	_check_double_tap(Input.is_action_just_pressed("move_right"))
	_check_double_tap(Input.is_action_just_pressed("move_left"))
	flip_sprite(movement_direction)
	
func play_animation(animation_name: StringName)-> void:
	# Función expuesta para que los estados puedan controlar la animación
	if animated_player.sprite_frames.has_animation(animation_name):
		animated_player.play(animation_name)
	
func flip_sprite(direction: int) -> void:
	if direction != 0:
		animated_player.flip_h = direction < 0
		
# dash (Debería moverse al PlayerDashState, pero lo mantengo aquí por ahora)

func _check_double_tap(is_moving: bool) -> void:
	if is_moving && finish_colddown_dash:
		if waiting_second_tap:
			_start_dash()
			waiting_second_tap = false
			double_tap_timer.stop()
		else:
			waiting_second_tap = true
			double_tap_timer.start()

func _start_dash()-> void:
	dash_timer.start()
	is_dashing = true
	
func _finish_dash()-> void:
	is_dashing = false
	
func _on_dash_timer_timeout() -> void:
	_finish_dash()

func _finish_waiting_for_second_tap() -> void:
	waiting_second_tap = false
	
func _on_double_tap_timer_timeout() -> void:
	_finish_waiting_for_second_tap()

func _on_dash_cold_down_timeout() -> void:
	finish_colddown_dash = true
	particles_timer.start()



# moving player
func want_moving() -> bool:
	return movement_direction != 0
	
# Estas funciones de movimiento y detención son redundantes con el State Machine
# y generan conflictos, por lo que su uso debe ser delegado a los PlayerState.gd
func move_player(_delta: float):
	var current_movement_speed = velocity.x + (movement_direction * acceleration * _delta)
	velocity.x = clamp(current_movement_speed, -movement_speed_limit, movement_speed_limit)
	play_animation("walk")

func stop_player(_delta: float):
	velocity.x = lerp(velocity.x, 0.0, friction_weight * _delta) if abs(velocity.x) > 1 else 0
	play_animation("idle")

func can_use_swim_boost() -> bool:
	return count_swim_boost > 0 && jump && finish_colddown_swim_boost

func _on_swim_boost_cold_down_timeout() -> void:
	finish_colddown_swim_boost = true

func change_absolute_direction(angle: float):
	# 0 grados: Right
	# 90 grados (pi/2): Bottom
	# 180 grados (pi): Left
	# 270 grados (3*pi/2) o -90 grados: up
	particles.rotation = deg_to_rad(angle)

func emit_particles(angle: float) -> void:
	particles.emitting = true
	particles_timer.start()

func _on_particles_timer_timeout() -> void:
	particles.emitting = false

func _on_particles_general_timer_timeout() -> void:
	change_absolute_direction(-90)
	particles.emitting = !particles.emitting 
