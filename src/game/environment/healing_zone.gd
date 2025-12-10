extends Area2D
class_name HealingZone
@onready var timer: Timer = $Timer
@export var wait_time: float = 1.5
@export var hp: float = 1

var target_player: Player
var is_healing: bool = false

func _physics_process(_delta: float) -> void:
	if can_healing_player(): 
		healing_player()
		
func can_healing_player() -> bool:
	return not is_healing and target_player
	
func healing_player() -> void:
	is_healing = true
	target_player.sum_hp(hp)
	timer.start()

func _on_timer_timeout() -> void:
	is_healing = false

func _on_body_entered(body: Node2D) -> void:
	target_player = body as Player

func _on_body_exited(_body: Node2D) -> void:
	target_player = null
