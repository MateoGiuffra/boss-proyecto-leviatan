extends Area2D
class_name Goal
@onready var portal: AnimatedSprite2D = $Portal
# esta variable es para asignar desde afuera. El valor minimo de items a agarrar para ganar
@export var min_items_amount: int = 1
@export var min_documentables_amount: int = 1
@export var level: GameLevel

@export var boss: Area2D
var won: bool = false
var obtain_all: bool = false
var target_player: Player
var trying_to_win: bool = false

func initialize(inventory: Inventory): 
	target_player = GameState.current_player
	inventory.inventory_changed.connect(self.verify_win)
	inventory.document_registered.connect(self.verify_win)
	
func _ready() -> void:	
	_play_animation("idle")
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(_body: Node) -> void:
	if won:
		return
	if can_win():
		won = true
		GameState.notify_level_won()
		#_play_animation("open")


func can_win() -> bool:
	if target_player: 
		return  target_player.inventory.get_items().size() >= min_items_amount and \
				target_player.zones.size() >= min_documentables_amount and \
				target_player.animated_player.animation != "shoot_camera" and \
				level and not trying_to_win
	target_player = GameState.current_player
	return false
	
func verify_win() -> void: 
	if can_win():
			trying_to_win = true
			boss._activate()	
			level.can_win_level.emit()

func _on_portal_animation_finished() -> void:
	if portal.animation == "open":
		_play_animation("idle_open")
		GameState.notify_level_won()

func _play_animation(animation_name: String):
	if portal.sprite_frames.has_animation(animation_name):
		portal.play(animation_name)
