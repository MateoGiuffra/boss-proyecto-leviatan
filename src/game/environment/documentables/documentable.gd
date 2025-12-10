extends Area2D
class_name DocumentableZone

@export var id: String = ""
@export var auto_hint: bool = true

func _on_body_entered(body: Node2D) -> void:
	body.on_photo_zone_player_entered(self, body)

func _on_body_exited(body: Node2D) -> void:
	body.on_photo_zone_player_exited(self, body)
