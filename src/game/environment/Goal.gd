extends Area2D

@onready var portal: AnimatedSprite2D = $Portal

var won: bool = false


func _ready() -> void:
	_play_animation("idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node) -> void:
	if won:
		return
	print("You win!")
	won = true
	_play_animation("open")

func _on_portal_animation_finished() -> void:
	if portal.animation == "open":
		_play_animation("idle_open")
		GameState.notify_level_won()

func _play_animation(animation_name: String):
	if portal.sprite_frames.has_animation(animation_name):
		portal.play(animation_name)
