extends Control
@onready var music_history: AudioStreamPlayer = $MusicHistory
@onready var monster_sea: AudioStreamPlayer = $MonsterSea
@export var level_manager_scene: PackedScene
@onready var story_image: TextureRect = $StoryImage
const STORY_FIRST_IMAGE = preload("uid://ck8lx3g0527a5")
const STORY_SECOND_IMAGE = preload("uid://dwlqg7sx7rukj")
const STORY_THIRD_IMAGE = preload("uid://citg5j5o6461o")
const STOTY_FOURTH_IMAGE = preload("uid://cdqa4d2xua8lj")
@onready var tutorial: Control = $Tutorial

var images: Array[Resource] = [STORY_FIRST_IMAGE, STORY_SECOND_IMAGE, STORY_THIRD_IMAGE, STOTY_FOURTH_IMAGE]

var fragments = []
var current_index = 0
var texts
var button

func _enter_tree():
	fragments = $MarginContainer.get_children()
	for f in fragments:
		f.visible = false

func _ready():
	show_fragment(0)
	

func _update_text(label: Label) -> void:
	if label and label.text.contains("(physical)"):
		label.text = normalize_text(label.text)

func normalize_text(text: String) -> String:
	return text.replace("_", " ").strip_escapes().replace("(physical)", "").capitalize()
	
func set_current_key(key_binding: String, label: Label) -> void:
	var events = InputMap.action_get_events(key_binding)
	
	for ev in events:
		if ev is InputEventKey:
			var text: String = normalize_text(ev.as_text())		
			label.text = text

func set_current_movement_key(key_binding: String, label: Label, ) -> void:
	set_current_key(key_binding, label)
	label.text =  key_binding.capitalize() + " - " + label.text
	
func show_fragment(index):
	for i in range(fragments.size()):
		fragments[i].visible = (i == index)
	
	story_image.texture = images[index]
	texts = fragments[index].get_node("VBoxTexts")
	button = fragments[index].get_node("NextScene")
	texts.play_fade()
	story_image.play_fade()
	
func _on_next_scene_pressed():
	await texts.play_fade_out()
	await story_image.play_fade_out()
	current_index += 1
	if current_index < fragments.size():
		show_fragment(current_index)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("saltear"):
		tutorial.play_fade()

func _on_last_scene_pressed() -> void:
	await texts.play_fade_out()
	await story_image.play_fade_out()
	if button.has_method("play_fade_out"): 
		await button.play_fade_out()
	
	var tween_audio = get_tree().create_tween()
	tween_audio.tween_property(music_history, "volume_db", -80, 2)
	await tween_audio.finished
	monster_sea.play()
	await monster_sea.finished
	
	tutorial.play_fade()
		
func _on_new_scene_pressed() -> void:
	get_tree().change_scene_to_packed(level_manager_scene)
