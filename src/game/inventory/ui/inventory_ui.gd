class_name InventoryUI extends Control

#const SLOT_SCENE = preload("uid://dogaewk7x4u0q")
@export var SLOT_SCENE: PackedScene
@onready var documentable_slot: Slot = $VBoxContainer/MarginContainer/HBoxContainer/DocumentableSlot
@onready var pick_up_slot: Slot = $VBoxContainer/MarginContainer/HBoxContainer/PickUpSlot


@onready var v_box_container: VBoxContainer = $VBoxContainer
var slots = []
var player_inventory: Inventory = null
var current_total: int = 0
var documents_total: int = 0

func _ready() -> void:
	_update_slot_text(documentable_slot, 0)
	_update_slot_text(pick_up_slot, 0)
	_update_ui()

func initialize(inventory: Inventory):
	self.player_inventory = inventory
	inventory.inventory_changed.connect(self._update_efficient)
	inventory.document_registered.connect(self._register_document)


func _register_document() -> void: 
	documents_total += 1
	_update_slot_text(documentable_slot, documents_total)

func _update_efficient(): 
	current_total += 1
	_update_slot_text(pick_up_slot, current_total)

func _update_slot_text(slot: Slot, total: int):
	slot.update_text(str(total) + "/" + str(slot.get_text()))

func _update_ui():
	pass

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
	
	# 3. Agregar al contenedor
	v_box_container.add_child(slot)
