extends Area2D
@export var oxygen_amount: int = 10
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var delete_timer: Timer = $DeleteTimer

func _on_body_entered(body: Node2D) -> void:
	var player: Player = body
	player.add_oxygen(oxygen_amount)
	audio_stream_player_2d.play()
	delete_timer.start()
	
func delete() -> void:
	queue_free()	


func _on_delete_timer_timeout() -> void:
	delete()
