extends Node

@export var initial_state: State
@onready var player: CharacterBody2D = $Player

var current_state: State
var states: Dictionary = {}

func _ready() -> void: #setUp del state machine
	for child in get_children(): 
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	
	if initial_state: 
		initial_state.enter()
		current_state = initial_state
		

func _process(delta: float) -> void: #encargado de la velocidad de los fotogramas
	if current_state: 
		current_state.update(delta)

func _physics_process(delta: float) -> void: #encargado del servidor de físicas
	if current_state:
		current_state.physics_update(delta)
	
func on_child_transition(state: State, new_state_name: String) -> void: 
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state: 
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
		
	
