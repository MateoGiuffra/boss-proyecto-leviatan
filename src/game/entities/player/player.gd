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
@export var max_hp: float = 5
var hp: float = max_hp
@onready var healing_sound: AudioStreamPlayer = $Sounds/HealingSound

# oxigeno
@export var max_oxygen: float = 100
var oxygen: float = 100
@onready var oxygen_bar: ProgressBar = $Pivot/OxygenBar
@export var oxygen_damage: float = 10
# visual
@onready var pivot: Node2D = $Pivot
@onready var animated_player: AnimatedSprite2D = $Pivot/AnimatedPlayer
@onready var inventory: Inventory = $Inventory
@onready var particles_timer: Timer = $Timers/ParticlesTimer
@onready var camera: Camera2D = $Camera
@onready var camera_point_light: PointLight2D = $Pivot/CameraPointLight

@onready var particles: CPUParticles2D = $CPUParticles2D
# oxygen bar visuals
@export var OXYGEN_IDLE_OFFSET   := Vector2(25.278, -29.656)
@export var OXYGEN_MOVING_OFFSET := Vector2(25.278, -37.656)
@export var OXYGEN_JUMP_OFFSET := Vector2(25.278, -39.656)

# labels
@onready var message: Label = $Message/Label
@onready var come_back_label: Label = $Message/ComeBackLabel

# timers
@onready var double_tap_timer: Timer = $Timers/DoubleTapTimer
@onready var dash_timer: Timer = $Timers/DashTimer
@onready var die_timer: Timer = $Timers/DieTimer
@onready var h20_timer: Timer = $Timers/H20Timer

# sounds
@onready var swimming_sound: AudioStreamPlayer = $Sounds/SwimmingSound
@onready var idle_sound: AudioStreamPlayer = $Sounds/IdleSound
@onready var hard_breathing_sound: AudioStreamPlayer = $Sounds/HardBreathingSound
@onready var sounds: Node = $Sounds
@onready var can_shoot_sound: AudioStreamPlayer = $Sounds/CanShootSound
@onready var shoot_camera_sound: AudioStreamPlayer = $Sounds/ShootCameraSound
@onready var documentable_sound: AudioStreamPlayer = $Sounds/DocumentableSound
@onready var damage_sound: AudioStreamPlayer = $Sounds/DamageSound

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

# documentables
var can_take_photo: bool = false
var is_taking_photo: bool = false
var current_photo_zone: DocumentableZone = null
var zones: Array[String] = []

# signals 
signal hp_changed(current_hp: float, max_hp: float)


func _ready():
	activate()

func activate(restart_level: bool = false):
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	show()
	if inventory_ui == null:
		var ui_nodes: Array = get_tree().get_nodes_in_group("ui_layer")
		if !ui_nodes.is_empty():
			inventory_ui = ui_nodes.get(0)
				
	if inventory_ui != null:
		goal.initialize(inventory)
		inventory_ui.initialize(inventory)

	hide_label(come_back_label)
	oxygen_bar.show()
	animated_player.scale = Vector2(4, 4)
	particles.emitting = false
	message.modulate.a = 1.0
	come_back_label.modulate.a = 0.0

	set_oxygen_bar_initial_values(restart_level)  
	_reset_shaders()                 

	if camera:
		camera.enabled = true
	GameState.set_current_player(self)

	
func set_oxygen_bar_initial_values(restart_level: bool = false) -> void:
	if restart_level:
		self.oxygen = max_oxygen              
	self.oxygen_bar.min_value = 0
	self.oxygen_bar.max_value = self.max_oxygen
	self.oxygen_bar.value = self.oxygen
	update_oxygen_overlay()          
	set_oxygen_bar_idle_position()

func _reset_shaders() -> void:
	var oxy_mat = oxygen_overlay.material
	if oxy_mat:
		oxy_mat.set_shader_parameter("intensity", 0.0)

	var dmg_mat = damage_overlay.material
	if dmg_mat:
		dmg_mat.set_shader_parameter("intensity", 0.0)


func set_oxygen_bar_idle_position() -> void:
	pass
	
func set_oxygen_bar_moving_position() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if !is_on_floor() and not swimming_sound.playing:
		swimming_sound.play()
	
	if is_dead():
		GameState.level_lost.emit()
	
	_play_sounds()
	get_input()
	_update_photo_zone_state()
	if goal.can_win():
		show_come_back_message()

	move_and_slide()
	
func _play_sounds() -> void:
	if has_low_oxygen():
		hard_breathing_sound.play()
	else:
		idle_sound.play()	

func has_low_oxygen() -> bool:
	return max_oxygen / 4 <= oxygen

func desactivate(hide_player = true):
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	canvas_layer.set_physics_process(true)
	oxygen_overlay.set_physics_process(true)
	damage_overlay.set_physics_process(true)
	stop_all_sounds(true)
	if hide_player:
		hide()
	if camera:
		camera.enabled = false

func _on_item_detector_area_entered(area: Area2D):
	if area.has_method("get_item_data"):
		var world_item_data: ItemData = area.get_item_data()
		
		if inventory.pick_up_item(world_item_data):
			area.pick_up()

func get_input() -> void:
	movement_direction = int(Input.is_action_pressed("derecha")) - int(Input.is_action_pressed("izquierda"))	
	jump = Input.is_action_just_pressed("saltar")
	_check_double_tap(Input.is_action_just_pressed("dash"))
	if Input.is_action_just_pressed("sacar_foto"):
		_try_take_photo()
	_update_visuals(movement_direction)
	
func play_animation(animation_name: StringName)-> void:
	if animated_player.sprite_frames.has_animation(animation_name):
		animated_player.play(animation_name)
	
func _update_visuals(direction: int) -> void:
	if direction != 0:
		var is_left := direction < 0
		pivot.scale.x = -1.0 if is_left else 1.0

	# offsets por estado físico real
	if not is_on_floor():
		oxygen_bar.position.y = OXYGEN_JUMP_OFFSET.y if (velocity.y < 0.0) else OXYGEN_MOVING_OFFSET.y
	elif want_moving() or animated_player.animation in ["shoot_camera", "can_shoot"]:
		oxygen_bar.position.y = OXYGEN_MOVING_OFFSET.y
	else:
		oxygen_bar.position.y = OXYGEN_IDLE_OFFSET.y


		
# dash
func _check_double_tap(_is_dashing: bool) -> void:
	if _is_dashing && finish_colddown_dash && want_moving():
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
	
	if is_dead():
		play_animation("die")
		return
	
	if is_taking_photo or can_take_photo:
		return
	
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

	if is_dead():
		play_animation("die")
		return

	if is_taking_photo or can_take_photo:
		return

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
	particles.rotation = deg_to_rad(angle)

func emit_particles(_angle: float) -> void:
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
	tween.tween_property(label, "modulate:a", 0.0, 0.5)

func _on_message_timer_timeout() -> void:
	hide_label(message)
	
func show_come_back_message() -> void:
	var tween = create_tween()
	tween.tween_property(come_back_label, "modulate:a", 1.0, 0.5)

# funciones claves como win, lost, damage_player etc
func win() -> void:
	hide_label(come_back_label)
	hide()

# funciones relacionadas al daño y la muerte
func is_dead():
	return hp <= 0 or oxygen <= 0


func damage_player(damage: float = 1, apply_knockback: bool = false) -> void:
	if is_dead():
		return
	hp -= damage
	damage_sound.play()
	damage_flash()
	if apply_knockback:
		_apply_hit_knockback()
	if is_dead():
		die_finish()
	hp_changed.emit(hp, max_hp)

func _apply_hit_knockback() -> void:
	var facing_dir = pivot.scale.x
	if facing_dir == 0.0:
		facing_dir = 1.0

	velocity.y = jump_speed if velocity.y < 0 else -jump_speed
	velocity.x = -facing_dir * movement_speed_limit
	is_dashing = false

		
func _on_die_timer_timeout() -> void:
	GameState.current_player_changed.emit()

func die_finish() -> void: 
	hp = 0
	oxygen = 0
	oxygen_bar.hide()
	animated_player.scale = Vector2(8, 8)
	hide_label(come_back_label)
	die_timer.start()
	stop_all_sounds(true)
	play_animation("die")

func stop_all_sounds(active: bool) -> void:
	for sound in get_sounds():
		if not active:
			sound.play()
		else:
			sound.stop()
			
			
func get_sounds() -> Array[AudioStreamPlayer]:
	var result: Array[AudioStreamPlayer] = []
	for child in sounds.get_children():
		if child is AudioStreamPlayer:
			result.append(child)
	return result


func damage_flash():
	var mat = damage_overlay.material
	mat.set_shader_parameter("intensity", 1.0)

	var tween := get_tree().create_tween()
	tween.tween_method(
		func(v): mat.set_shader_parameter("intensity", v),
		1.0, 0.0, 0.75
	)

func sum_hp(amount: float) -> void:
	if hp != max_hp:
		healing_sound.play()
	hp = clamp(hp + amount, 0, max_hp)
	hp_changed.emit(hp, max_hp)

# h20 
func _on_h_20_timer_timeout() -> void:
	lose_oxygen(oxygen_damage)
	h20_timer.start()

func lose_oxygen(_oxygen: int = 10)-> void: 
	self.oxygen -= _oxygen
	update_oxygen_bar()
	
func add_oxygen(_new_oxygen: int) -> void:
	self.oxygen = min(self.oxygen + oxygen_damage, max_oxygen)
	update_oxygen_bar()

func update_oxygen_bar() -> void: 
	var tween = get_tree().create_tween()
	tween.tween_property(oxygen_bar, "value", oxygen, 0.2)
	update_oxygen_overlay()
	
func update_oxygen_overlay() -> void:
	var shader = oxygen_overlay.material
	shader.set_shader_parameter("intensity", 1.0 - (oxygen / max_oxygen))

# documentables
func can_player_take_photo(zone: DocumentableZone) -> bool:
	return zone != null \
		and is_on_floor() \
		and not want_moving() \
		and not is_taking_photo \
		and not zones.has(zone.id)

func on_photo_zone_player_entered(zone: DocumentableZone, _player: Player) -> void:
	documentable_sound.play()
	current_photo_zone = zone

func on_photo_zone_player_exited(zone: DocumentableZone, _player: Player) -> void:
	if current_photo_zone == zone: 
		current_photo_zone = null
		can_take_photo = false
		if not is_taking_photo and is_on_floor():
			play_animation("idle")

# Se llama en _physics_process cada frame
func _update_photo_zone_state() -> void:
	if current_photo_zone == null:
		can_take_photo = false
		return

	if is_taking_photo:
		return

	var should_enable = can_player_take_photo(current_photo_zone)

	if should_enable and not can_take_photo:
		can_take_photo = true
		_show_ready_to_shoot_pose()
	elif not should_enable and can_take_photo:
		can_take_photo = false
		if is_on_floor() and not want_moving() and not is_dashing and not is_dead():
			play_animation("idle")

func _show_ready_to_shoot_pose() -> void:
	# Pose estática con la cámara abajo (último frame de can_shoot)
	if not animated_player.sprite_frames.has_animation("can_shoot"):
		return
	var last_frame := animated_player.sprite_frames.get_frame_count("can_shoot") - 1
	if last_frame < 0:
		return
	can_shoot_sound.play()
	animated_player.animation = "can_shoot"
	animated_player.frame = last_frame
	animated_player.pause()

func _try_take_photo() -> void:
	if not can_player_take_photo(current_photo_zone):
		return
	zones.append(current_photo_zone.id)
	can_take_photo = false
	is_taking_photo = true
	shoot_camera_sound.play()
	camera_point_light.enabled = true
	play_animation("shoot_camera")

func _on_animated_player_animation_finished() -> void:
	match animated_player.animation: 
		"shoot_camera":
			_on_photo_shoot_finished()

func _on_photo_shoot_finished() -> void: 
	camera_point_light.enabled = false
	is_taking_photo = false
	can_take_photo = false
	if is_on_floor():
		if want_moving():
			play_animation("walk")
		else:
			play_animation("idle")
	else:
		if velocity.y < 0.0:
			play_animation("jump")
		else:
			play_animation("fall")
	inventory.document_registered.emit()
	
# camera
func screen_shake(duration: float = 0.3, magnitude: float = 12.0) -> void:
	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	for i in range(6):
		var random_offset := Vector2(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude)
		)
		tween.tween_property(self, "offset", random_offset, duration / 6.0)

	# volver a offset 0 al final
	tween.tween_property(self, "offset", Vector2.ZERO, duration / 6.0)
	await tween.finished
