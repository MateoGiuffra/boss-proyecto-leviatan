class_name InventoryUI extends Control

#const SLOT_SCENE = preload("uid://dogaewk7x4u0q")
@export var SLOT_SCENE: PackedScene

@onready var v_box_container: VBoxContainer = $VBoxContainer
var slots = []
var player_inventory: Inventory = null

func initialize(inventory: Inventory):
	self.player_inventory = inventory
	inventory.inventory_changed.connect(self._update_ui)
	_update_ui()

func _update_ui():
	for slot in slots: 
		slot.queue_free()
	slots = []
	for item in player_inventory.get_items():
		var slot = SLOT_SCENE.instantiate()
		
		var icon_node: TextureRect = slot.get_node("Icon")
		var amount_node: Label = slot.get_node("Amount")
		
		icon_node.texture = item.icon
		amount_node.text = str(item.actual_amount)
		
		self._config_dimensions(icon_node, amount_node, slot)
		self._add(slot)

func _add(slot ):
	slots.append(slot)

func _config_dimensions(icon_node, amount_node,slot):
	# --- CONFIGURACIÓN DE DIMENSIONES (ÍCONO) ---
	icon_node.custom_minimum_size = Vector2(32, 32)
	icon_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	# --- CONFIGURACIÓN DE DIMENSIONES (CANTIDAD) ---
	# 1. Establece el tamaño mínimo personalizado al mismo tamaño del ícono (32x32)
	amount_node.custom_minimum_size = Vector2(32, 32) 
	
	# 2. Centra el texto dentro de ese espacio
	amount_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	amount_node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# 3. [Opcional] Para que el texto se vea bien encima del ícono, puedes 
	#    agregarle un color de fondo temporal o un Outline/Shadow.
	
	# 3. Agregar al contenedor
	v_box_container.add_child(slot)
