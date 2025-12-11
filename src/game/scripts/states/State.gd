@abstract
class_name State extends Node

signal Transitioned

@abstract func get_input() -> void
@abstract func enter() -> void
@abstract func exit() -> void
@abstract func update(_delta: float) -> void
@abstract func physics_update(_delta: float) -> void

func play_random_sound(sound_list, stream_player: AudioStreamPlayer):
	if sound_list.size() > 0:
		stream_player.stream = sound_list[randi() % sound_list.size()]
	
	stream_player.play()
