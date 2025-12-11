extends Node
@onready var point_light_red: Node2D = $PointLightRed
@onready var point_light_green: Node2D = $PointLightGreen

@export var light_layer:int = 7  # la capa de luz que querés usar

func _ready() -> void:
	set_layer(point_light_red)
	set_layer(point_light_green)
	
func set_layer(node: Node2D) -> void: 
	for child in node.get_children():
		if child is PointLight2D:
			child.light_mask = 1 << 6
