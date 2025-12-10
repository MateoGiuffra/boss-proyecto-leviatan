extends CanvasLayer
class_name UILife
@onready var health_ui_container: HealthUI = $VBoxContainer/MarginContainer/HealthUIContainer

var current_player: Player

func _ready() -> void:
	GameState.current_player_changed.connect(_on_current_player_changed)
	if GameState.current_player != null:
		_on_current_player_changed(GameState.current_player)

func _on_current_player_changed(player: Player) -> void:
	current_player = player
	current_player.hp_changed.connect(_on_player_hp_changed)
	_on_player_hp_changed(current_player.hp, current_player.max_hp)

func _on_player_hp_changed(current_hp: float, max_hp: float) -> void:
	health_ui_container.set_health(current_hp, max_hp, true)
