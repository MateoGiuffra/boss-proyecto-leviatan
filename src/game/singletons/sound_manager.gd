extends Node


var hover_sound = preload("res://assets/sound/soundtracks/hover-button-287656.mp3")

func play_hover_sound(ui_audio_player: AudioStreamPlayer):
	if ui_audio_player:
		ui_audio_player.stream = hover_sound
		ui_audio_player.play() 
