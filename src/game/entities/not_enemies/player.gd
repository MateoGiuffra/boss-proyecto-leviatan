extends CharacterBody2D
class_name Player

# Parametros que serán gestionados por el State Machine
@export var acceleration: float = 3750.0
@export var movement_speed_limit: float = 300.0
@export var friction_weight: float = 6.25
@export var dash_speed: float = 1200.0
@export var gravity: float = 725.0
@export var jump_speed: int = 450
@export var swim_boost: int = 3
@export var inventory_ui: InventoryUI
@export var goal: Area2D
@onready var state_machine = $StateMachine

# salud
@export var max_hp: int = 3
var hp: int = max_hp

# oxigeno
@export var max_oxygen: float = 100
var oxygen: float = 100
@onready var oxygen_bar: ProgressBar = $Pivot/OxygenBar

# visual
@onready var pivot: Node2D = $Pivot
@onready var animated_player: AnimatedSprite2D = $Pivot/AnimatedPlayer
const OXYGEN_IDLE_OFFSET   := Vector2(25.278, -28.656)
const OXYGEN_MOVING_OFFSET := Vector2(25.278, -37.656)
var _oxygen_current_offset: Vector2 = OXYGEN_IDLE_OFFSET
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var inventory: Inventory = $Inventory
@onready var particles_timer: Timer = $Timers/ParticlesTimer
@onready var camera: Camera2D = $Camera
@onready var message: Label = $Message/Label
@onready var come_back_label: Label = $Message/ComeBackLabel
@onready var items_life: HBoxContainer = $"../UILife/VBoxContainer/MarginContainer/HBoxContainer"
@onready var particles: CPUParticles2D = $CPUParticles2D

# timers
@onready var double_tap_timer: Timer = $Timers/DoubleTapTimer
@onready var dash_timer: Timer = $Timers/DashTimer

# sounds
@onready var swimming_sound: AudioStreamPlayer2D = $Sounds/SwimmingSound

# timers
@onready var h20_timer: Timer = $Timers/H20Timer

# shaders
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var oxygen_overlay: ColorRect = $CanvasLayer/ColorRectOxygenMark
@onready var damage_overlay: ColorRect = $CanvasLayer/ColorRectDamage

# Variables para la logica del dash y swim boost
var movement_direction: int
var count_swim_boost = swim_boost
var jump: bool
var is_dashing: bool
var waiting_second_tap: bool
var finish_colddown_dash: bool = true
var finish_colddown_swim_boost: bool = true

# signals 
signal hp_changed(current_hp: int, max_hp: int)

func _ready():
	if inventory_ui == null:
		var ui_nodes: Array = get_tree().get_nodes_in_group("ui_layer")
		if !ui_nodes.is_empty():
			inventory_ui = ui_nodes.get(0)
				
	if inventory_ui != null:
		goal.initialize(inventory)
		inventory_ui.initialize(inventory)
	
	oxygen_bar.show()
	animated_player.scale.x = 4
	animated_player.scale.y = 4
	particles.emitting = false
	message.modulate.a = 1.0
	come_back_label.modulate.a = 0.0
	set_oxygen_bar_initial_values()
	GameState.set_current_player(self)

func set_oxygen_bar_initial_values() -> void:
	self.oxygen_bar.min_value = 0
	self.oxygen_bar.max_value = self.max_oxygen
	self.oxygen_bar.value = self.max_oxygen
	set_oxygen_bar_idle_position()

func set_oxygen_bar_idle_position() -> void:
	pass
	
func set_oxygen_bar_moving_position() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if !is_on_floor() and not swimming_sound.playing:
		swimming_sound.play()
	
	if is_dead():
		GameState.level_lost.emit()
	
	get_input()
	
	if inventory.items_amount() == goal.min_amount:
		show_come_back_message()

	move_and_slide()
	
		

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

	
func get_input() -> void:
	movement_direction = int(Input.is_action_pressed("derecha")) - int(Input.is_action_pressed("izquierda"))	
	jump = Input.is_action_just_pressed("saltar")
	_check_double_tap(Input.is_action_just_pressed("dash"))
	_update_visuals(movement_direction)
	
func play_animation(animation_name: StringName)-> void:
	# Función expuesta para que los estados puedan controlar la animación
	if animated_player.sprite_frames.has_animation(animation_name):
		animated_player.play(animation_name)
	
func _update_visuals(direction: int) -> void:
	if direction != 0:
		var is_left := direction < 0
		pivot.scale.x = -1.0 if is_left else 1.0
		oxygen_bar.position.y = -37.826
	else: 
		oxygen_bar.position.y = -29.826
		
# dash (Debería moverse al PlayerDashState, pero lo mantengo aquí por ahora)
func _check_double_tap(is_dashing: bool) -> void:
	if is_dashing && finish_colddown_dash && want_moving():
		_start_dash()

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
	
# moving

func want_moving() -> bool:
	return movement_direction != 0

func move_player(delta: float) -> void:
	var current_movement_speed = velocity.x + (movement_direction * acceleration * delta)
	velocity.x = clamp(current_movement_speed, -movement_speed_limit, movement_speed_limit)
	
	if is_dashing:
		play_animation("dash")
		return

	if not is_on_floor():
		if velocity.y < 0.0:
			play_animation("jump")  
		else:
			play_animation("fall")  
	else:
		if want_moving():
			play_animation("walk")
		else:
			play_animation("idle")

func stop_player(delta: float) -> void:
	velocity.x = lerp(velocity.x, 0.0, friction_weight * delta) if abs(velocity.x) > 1 else 0

	if is_dashing:
		play_animation("dash")
		return

	if is_on_floor():
		play_animation("idle")
	else:
		if velocity.y < 0.0:
			play_animation("jump")
		else:
			play_animation("fall")


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

# particulas
func _on_particles_timer_timeout() -> void:
	particles.emitting = false

func _on_particles_general_timer_timeout() -> void:
	change_absolute_direction(-90)
	particles.emitting = !particles.emitting 

# mensajes
func hide_label(label: Label) -> void: 
	var tween = create_tween()
	tween.tween_property(message, "modulate:a", 0.0, 0.5)

func _on_message_timer_timeout() -> void:
	hide_label(message)
	
func show_come_back_message() -> void:
	var tween = create_tween()
	tween.tween_property(come_back_label, "modulate:a", 1.0, 0.5)

# funciones claves como win, lost, beaten etc
func win() -> void:
	hide_label(come_back_label)
	hide()

# funciones relacionadas al daño y la muerte
func is_dead():
	return hp <= 0 or oxygen <= 0

func die_finish() -> void: 
	var new_parent = get_parent()
	remove_child(camera)
	new_parent.add_child(camera) 
	remove_child(point_light_2d) 
	new_parent.add_child(point_light_2d)
	animated_player.scale.x = 8
	animated_player.scale.y = 8
	oxygen_bar.hide()
	play_animation("die")

func _on_animated_player_animation_finished() -> void:
	# --- Lógica de Muerte del Player ---
	hp = 0
	hide()
	queue_free() 

func beaten() -> void:
	hp -= 1
	damage_flash()
	print("sacar vida")
	#var life_to_remove = items_life.get_child(items_life.get_child_count() - 1)
	#life_to_remove.queue_free()
	
	if hp <= 0:
		die_finish()

func damage_flash():
	var mat = damage_overlay.material
	
	mat.set_shader_parameter("intensity", 1.0)

	var tween := get_tree().create_tween()
	tween.tween_method(
		func(v): mat.set_shader_parameter("intensity", v),
		1.0, 0.0, 0.75
	)

	
func sum_hp(amount: int) -> void:
	hp = clamp(hp + amount, 0, max_hp)
	hp_changed.emit(hp, max_hp)
	print("hp_changed %s %s" % [hp, max_hp])	

# h20 
func _on_h_20_timer_timeout() -> void:
	lose_oxygen(10)
	h20_timer.start()
	print(oxygen)

func lose_oxygen(oxygen: int )-> void: 
	self.oxygen -= 10 
	update_oxygen_bar()
	
func add_oxygen(new_oxygen: int) -> void:
	self.oxygen = min(self.oxygen + new_oxygen, max_oxygen)
	update_oxygen_bar()

func update_oxygen_bar() -> void: 
	var tween = get_tree().create_tween()
	tween.tween_property(oxygen_bar, "value", oxygen, 0.2)
	update_oxygen_overlay()
	
func update_oxygen_overlay() -> void:
	var shader = oxygen_overlay.material
	shader.set_shader_parameter("intensity", 1.0 - (oxygen / max_oxygen))
