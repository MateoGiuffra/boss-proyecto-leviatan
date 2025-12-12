extends Area2D
@onready var boss_animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var boss_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var roar_monster: AudioStreamPlayer = $RoarMonster
@export var speed: float = 200.0
var attack: bool = false
@export var player: Player = null
@onready var hitbox: Area2D = $Hitbox
@onready var sounds: Node = $Sounds
@onready var sound_timer: Timer = $SoundTimer

func _ready() -> void:
	desactivate()

func desactivate() -> void:
	hide()
	boss_animated.play()
	for sound in get_sound_players():
		if sound.playing:
			sound.stop()
	roar_monster.stop()
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	if attack:
		_move_enemy(delta)

func init_attack(): 
	attack = true

func _activate() -> void:
	show()
	hitbox.process_mode = Node.PROCESS_MODE_INHERIT
	boss_animated.play()
	roar_monster.play()
	play_random_sound()

func play_random_sound() -> void:
	var new_wait_time: int = int(randf_range(5.0, 10.0))
	sound_timer.wait_time = new_wait_time
	sound_timer.start()

func _move_enemy(delta: float):
	if not player: 
		player = GameState.current_player
	var direction = global_position.direction_to(player.global_position)
	var movement_vector = direction * speed * delta
	self.position += movement_vector
	if movement_vector.x != 0:
		boss_sprite.flip_h = movement_vector.x < 0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body

func _on_body_exited(body: Node2D) -> void:
	if body == player: 
		player = null

func _on_hitbox_body_entered(body: Player) -> void:
	body.die_finish()
	desactivate()

func get_sound_players() -> Array[AudioStreamPlayer2D]:
	var result: Array[AudioStreamPlayer2D] = []
	for child in sounds.get_children():
		if child is AudioStreamPlayer2D:
			result.append(child)
	return result

func _on_sound_timer_timeout() -> void:
	var sound_players := get_sound_players()
	if sound_players.is_empty():
		return
	var sound: AudioStreamPlayer2D = sound_players.pick_random()
	sound.play()
