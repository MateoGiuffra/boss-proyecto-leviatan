extends Area2D

@onready var entities_container: Node2D = $EntitiesContainer

# exports 
@export var initially_active = false
var dynamic_entities: Array[Node2D] = []

func _ready() -> void:
	turn_all(entities_container, initially_active)
	self.visible = true 

func turn_all(node, active: bool) -> void:
	if not node is Node2D or not node.has_method("get_children"):
		return 
	var children: Array[Node] = node.get_children()
	var final_process_mode: Node.ProcessMode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	
	for child in children: 
		if child.has_meta("visible"):
			child.visible = active
		if child is PointLight2D:
			if child.energy == 5:
				child.energy = 3
			child.enabled = active
		child.process_mode = final_process_mode
		turn_all(child, active)
	
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		add_dynamic_entity_to_list(body)
		return
	turn_all(self.entities_container, true) 
	turn_all_dynamic_entities(true)
	
func turn_all_dynamic_entities(active: bool) -> void: 
	for entity in dynamic_entities: 
		turn_all(entity, active)

func add_dynamic_entity_to_list(body: Node2D) -> void: 
	if body is Node2D and not dynamic_entities.has(body) : 
		dynamic_entities.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		turn_all(self.entities_container, false)
		turn_all_dynamic_entities(true)
	
