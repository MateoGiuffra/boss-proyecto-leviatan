extends Area2D
@onready var boss_animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var boss_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var roar_monster: AudioStreamPlayer = $RoarMonster
@export var speed: float = 200.0
var attack: bool = false
var player: CharacterBody2D = null

func _ready() -> void:
	boss_animated.play()

func _process(delta: float) -> void:
	if attack and player:
		_move_enemy(delta)
			
func init_attack(): 
	roar_monster.play()
	attack = true

func _move_enemy(delta: float):
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


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("die_finish"):
			body.die_finish()
