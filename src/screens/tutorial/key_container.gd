extends PanelContainer
@onready var key: Label = $Key

func set_text(text: String) -> void:
	key.text = text
