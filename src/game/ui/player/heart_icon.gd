extends Control
class_name HeartIcon

@export var full_texture: Texture2D
@export var half_texture: Texture2D
@export var empty_texture: Texture2D

@onready var outline: TextureRect = $Outline
@onready var icon: TextureRect = $Icon

enum State { EMPTY, HALF, FULL }
var state: HeartIcon.State = State.FULL

func set_state(new_state: HeartIcon.State) -> void:
	state = new_state
	match state:
		State.FULL:
			icon.texture = full_texture
		State.HALF:
			icon.texture = half_texture
		State.EMPTY:
			icon.texture = empty_texture

func flash_outline(times: int = 2, duration: float = 0.1) -> void:
	var tween := create_tween().set_loops(times)
	tween.tween_property(outline, "self_modulate:a", 0.0, duration).from(1.0)
	tween.tween_property(outline, "self_modulate:a", 1.0, duration)
