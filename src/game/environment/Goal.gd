extends Area2D

@onready var portal: AnimatedSprite2D = $Portal
@onready var inventory: Inventory = $Inventory

var won: bool = false
var obtain_all: bool = false
var amount: int = 0


func initialize(inventory: Inventory):
	inventory.inventory_changed.connect(self.update_amount)
	

func _ready() -> void:
	
	_play_animation("idle")
	body_entered.connect(_on_body_entered)
	
	

func _on_body_entered(_body: Node) -> void:
	if won:
		return
	
	if amount == 10:
		print("You win!")
		won = true
		GameState.notify_level_won()
		#_play_animation("open")
	
	
func update_amount() -> void: 
	print("Aumentooo")
	amount += 1

func _on_portal_animation_finished() -> void:
	if portal.animation == "open":
		_play_animation("idle_open")
		GameState.notify_level_won()

func _play_animation(animation_name: String):
	if portal.sprite_frames.has_animation(animation_name):
		portal.play(animation_name)
