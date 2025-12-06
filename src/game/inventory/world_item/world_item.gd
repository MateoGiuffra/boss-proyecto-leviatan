# WorldItem.gd
extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pick_up_sound: AudioStreamPlayer2D = $PickUpSound


# 🎯 Definimos un tamaño objetivo para el sprite en píxeles de Godot
# Por ejemplo, si quieres que todos los ítems en el mundo sean de 32x32 unidades.
const TARGET_SIZE: Vector2 = Vector2(32, 32) 
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var item_data: ItemData:
	set(value):
		item_data = value
		_update_visuals()

func _ready() -> void:
	item_data.play_pickup_sound.connect(pick_up_sound.play)

func _physics_process(delta: float) -> void:
	animation_player.play("idle")

# Función para que el Player obtenga los datos del ítem
func get_item_data() -> ItemData:
	return item_data

# Actualiza el Sprite con la textura del Resource y ajusta su tamaño
func _update_visuals():
	var sprite = sprite_2d
	var collision_shape = collision_shape_2d

	if sprite and item_data and item_data.icon:
		sprite.texture = item_data.icon
		
		# --- 1. AJUSTE DEL TAMAÑO VISUAL (Sprite2D) ---
		var texture_size: Vector2 = sprite.texture.get_size()
		
		# Calculamos el factor de escala necesario para alcanzar TARGET_SIZE
		if texture_size.x > 0 and texture_size.y > 0:
			var scale_x = TARGET_SIZE.x / texture_size.x
			var scale_y = TARGET_SIZE.y / texture_size.y
			
			# Usamos la escala de tal forma que el sprite tenga TARGET_SIZE
			sprite.scale = Vector2(scale_x, scale_y)
			
		# --- 2. OPCIONAL: Ajustar el tamaño de la Colisión al Sprite escalado ---
		# Si quieres que la colisión sea igual al tamaño visual 32x32:
		if collision_shape:
			# Verifica si la forma es un RectangleShape2D o similar
			var shape = collision_shape.shape
			if shape is RectangleShape2D:
				# Establece la extensión (half-size) de la forma al TARGET_SIZE / 2
				shape.extents = TARGET_SIZE / 2.0
				
	else:
		# Si no hay ícono o item_data, aseguramos que el sprite y la colisión no se muestren/actúen
		if sprite:
			sprite.texture = null
		if collision_shape:
			# Desactivar la colisión si no hay ítem
			collision_shape.set_deferred("disabled", true)
