extends Control
@onready var music_history: AudioStreamPlayer = $MusicHistory
@onready var monster_sea: AudioStreamPlayer = $MonsterSea
@export var level_manager_scene: PackedScene
@onready var tutorial: Control = $Tutorial


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
		
func show_fragment(index):
	for i in range(fragments.size()):
		fragments[i].visible = (i == index)

	texts = fragments[index].get_node("VBoxTexts")
	button = fragments[index].get_node("NextScene")
	texts.play_fade()
	
func _on_next_scene_pressed():
	await texts.play_fade_out()
	current_index += 1
	if current_index < fragments.size():
		show_fragment(current_index)


func _on_last_scene_pressed() -> void:
	await texts.play_fade_out()
	await button.play_fade_out()
	
	var tween_audio = get_tree().create_tween()
	tween_audio.tween_property(music_history, "volume_db", -80, 2)
	await tween_audio.finished
	monster_sea.play()
	await monster_sea.finished
	
	tutorial.play_fade()
	
	
	
func _on_new_scene_pressed() -> void:
	get_tree().change_scene_to_packed(level_manager_scene)
