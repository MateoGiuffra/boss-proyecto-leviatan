extends Area2D

@onready var entities_container: Node2D = $EntitiesContainer
@onready var shape_node: CollisionShape2D = $CollisionShape2D

# exports 
@export var area_shape: Shape2D
@export var initially_active := false

func _ready() -> void:
	if area_shape:
		shape_node.shape = area_shape
	else:
		push_warning("Chunk sin shape configurada")
	turn_all(entities_container, initially_active)
	self.visible = true 

func turn_all(node, active: bool) -> void:
	if not node is Node2D or not node.has_method("get_children"):
		return 
	var children: Array[Node] = node.get_children()
	if children.is_empty():
		return 
	var final_process_mode: Node.ProcessMode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	
	for child in children: 
		if child.has_meta("visible"):
			child.visible = active
		if child is PointLight2D:
			child.enabled = active
		child.process_mode = final_process_mode
		turn_all(child, active)	

func _on_body_entered(body: Node2D) -> void:
	print(body)
	turn_all(self.entities_container, true)

func _on_body_exited(body: Node2D) -> void:
	turn_all(self.entities_container, false)
