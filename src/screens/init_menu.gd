extends CanvasLayer
@onready var hover_button: AudioStreamPlayer = $"../../Sound/HoverButton"


func _ready() -> void:
	connect_buttons_to_sound()
	
func connect_buttons_to_sound():
	var buttons = get_tree().get_nodes_in_group("ButtonUI") 

	for button in buttons:
		if button:
			button.mouse_entered.connect(SoundManager.play_hover_sound.bind(hover_button))
			hover_button.bus = "UI"
