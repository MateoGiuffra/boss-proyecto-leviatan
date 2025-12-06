extends Area2D
@export var oxygen_amount: int = 10
@onready var delete_timer: Timer = $DeleteTimer
@onready var pick_up_sound: AudioStreamPlayer2D = $PickUpSound

func _on_body_entered(body: Node2D) -> void:
	var player: Player = body
	player.add_oxygen(oxygen_amount)
	pick_up_sound.play()
	delete_timer.start()
	
func delete() -> void:
	queue_free()	


func _on_delete_timer_timeout() -> void:
	delete()
