@tool
extends Node

@export  var actionInput: String :
	set(inp):
		actionInput = inp
		if Engine.is_editor_hint() && has_node("$HBoxContainer/Panel/Input"):
			$HBoxContainer/Panel/Input.text = inp
@export var action: String:
	set(inpA):
		action = inpA
		if Engine.is_editor_hint() && has_node("$HBoxContainer/Action"):
			$HBoxContainer/Action.text = inpA
@onready var inputLabel: Label = $HBoxContainer/Panel/Input
@onready var actionLabel: Label = $HBoxContainer/Action

func _ready():
	inputLabel.text = actionInput
	actionLabel.text = action
