extends Area2D
class_name DocumentableZone

@export var id: String = ""
@export var auto_hint: bool = true

signal player_entered_zone(player: Player)
signal player_exited_zone(player: Player)

func _on_body_entered(body: Node2D) -> void:
	print("entro perra")
	body.on_photo_zone_player_entered(self, body)

func _on_body_exited(body: Node2D) -> void:
	print("sali perra")
	body.on_photo_zone_player_exited(self, body)
