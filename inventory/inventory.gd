class_name Inventory extends Node

var items: Dictionary[String, ItemData] = {} # Key: Item ID (String)
@export var inventory_size: int = 10

signal inventory_changed
# un cambio
func pick_up_item(world_item_data: ItemData) -> bool:
	var item_id: String = world_item_data.id
	if items.has(item_id):
		var existing_item = items[item_id]
		existing_item.collect_item()
		inventory_changed.emit()
		return true 

	if self._can_add_new_type():
		var new_item_copy = world_item_data.duplicate() as ItemData
		new_item_copy.collect_item() 
		items[item_id] = new_item_copy
		inventory_changed.emit()
		return true
		
	return false

func _can_add_new_type() -> bool:
	return items.size() < inventory_size

func get_items() -> Array[ItemData]:
	return items.values()
