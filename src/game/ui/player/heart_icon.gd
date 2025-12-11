extends Control
class_name HeartIcon

@export var full_texture: Texture2D
@export var half_texture: Texture2D
@export var empty_texture: Texture2D

@onready var outline: TextureRect = $Outline
@onready var icon: TextureRect = $Icon

enum State { EMPTY, HALF, FULL }
var state: HeartIcon.State = State.FULL

var _base_scale: Vector2

func _ready() -> void:
	# Guardamos la escala "normal" para usarla en las animaciones
	_base_scale = scale

func set_state(new_state: HeartIcon.State) -> void:
	var prev_state := state
	state = new_state

	match state:
		State.FULL:
			icon.texture = full_texture
			outline.hide()
		State.HALF:
			icon.texture = half_texture
			outline.show()
		State.EMPTY:
			icon.texture = empty_texture
			outline.show()

	# Si veníamos de EMPTY y ahora NO estamos vacíos, hacemos el bounce al aparecer
	if prev_state == State.EMPTY and state != State.EMPTY:
		play_appear_bounce()

func flash_outline(times: int = 2, duration: float = 0.1) -> void:
	var tween := create_tween().set_loops(times)
	tween.tween_property(outline, "self_modulate:a", 0.0, duration).from(1.0)
	tween.tween_property(outline, "self_modulate:a", 1.0, duration)

# --- ANIMACIÓN IDLE (wiggle / breathing effect) ---

func play_idle_wiggle() -> Tween:
	var tween := create_tween()

	var up_scale := _base_scale * Vector2(1.06, 1.06)
	var angle := deg_to_rad(4.0)

	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", up_scale, 0.09)
	tween.parallel().tween_property(self, "rotation", angle, 0.09)

	tween.tween_property(self, "scale", _base_scale, 0.11)
	tween.parallel().tween_property(self, "rotation", 0.0, 0.11)

	return tween


# --- ANIMACIÓN AL APARECER / RECUPERAR VIDA ---

func play_appear_bounce() -> void:
	# Corazón aparece: entra un poco grande y vuelve a la escala normal
	scale = _base_scale * Vector2(0.7, 0.7)  # arranca más chico si querés este efecto

	var tween := create_tween()
	var over_scale := _base_scale * Vector2(1.2, 1.2)

	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", over_scale, 0.12)
	tween.tween_property(self, "scale", _base_scale, 0.10)
