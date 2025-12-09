extends Area2D
@onready var boss_animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var boss_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var roar_monster: AudioStreamPlayer = $RoarMonster
@export var speed: float = 200.0
var attack: bool = false
@export var player: Player = null
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	desactivate()

func desactivate() -> void:
	hide()
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	boss_animated.play()
	audio_stream_player_2d.stop()
	roar_monster.stop()	

func _process(delta: float) -> void:
	if attack :
		_move_enemy(delta)
			
func init_attack(): 
	attack = true

func _activate() -> void:
	show()
	hitbox.process_mode = Node.PROCESS_MODE_INHERIT
	boss_animated.play()
	roar_monster.play()
	audio_stream_player_2d.play()

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
