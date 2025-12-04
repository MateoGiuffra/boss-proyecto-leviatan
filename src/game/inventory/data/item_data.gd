class_name ItemData extends Resource

@export var id: String = ""
@export var icon: Texture2D 
@export var description: String = ""

@export var stackeable = true 
@export var actual_amount = 0
@export var max_amount = 10

func is_stackeable() -> bool:
	return stackeable

# solo se debe llamar a esta funcion si la instancia es una copia y no una referencia
func add_to_inventory(inventory: Inventory, item_id: String = "empty") -> bool:
	if actual_amount + 1 > max_amount:
		return false
		
	if item_id != "empty" and item_id != id:
		return false
	
	if actual_amount == 0:
		actual_amount = 1 
		inventory.add(self) 
		return true
	elif stackeable:
		actual_amount += 1
		return true

	return false

func collect_item():
	if stackeable and self.actual_amount < self.max_amount:
		actual_amount += 1
		return true
	return false
	
