extends Area2D
@export var oxygen_amount: int = 10

func _on_body_entered(body: Node2D) -> void:
	var player: Player = body
	player.add_oxygen(oxygen_amount)
	queue_free()
		
