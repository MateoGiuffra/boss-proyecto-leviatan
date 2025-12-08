extends HBoxContainer
class_name Slot

@onready var amount: Label = $Amount
@onready var icon: TextureRect = $Icon

@export var sprite: Texture2D
@export var label: String = ""
var initial_label: String = label
func _ready() -> void:
	amount.text = label
	initial_label = label
	icon.texture = sprite

func update_text(text: String) -> void:
	amount.text = text

func get_text() -> String:	
	return initial_label
