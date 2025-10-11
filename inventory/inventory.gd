class_name Inventory extends Node

var items: Array[ItemData] = [] 
@export var inventory_size: int = 10 

signal inventory_changed

func pick_up_item(item_data: ItemData) -> bool:
	var new_item_copy = item_data.duplicate() as ItemData 
	
	for item in items:
		if new_item_copy.add_to_inventory(self, item.id):
			return true
	
	if self._can_pick_up_item(item_data):
		if new_item_copy.add_to_inventory(self):
			return true
	return false

func add(item_data: ItemData) -> void:
	items.append(item_data)
	inventory_changed.emit()
	print("items: \n")
	for idx in items.size():
		var item: ItemData = items[idx]
		print("Índice: " + str(idx) + ", Item ID: " + item.id)


func _can_pick_up_item(_item_data: ItemData) -> bool:
	return (items.size() < inventory_size)
