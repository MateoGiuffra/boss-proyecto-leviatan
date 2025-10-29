extends Node

@export var initial_state: State
@onready var enemy: CharacterBody2D = $".."

var current_state: State
var states: Dictionary = {}

func _ready() -> void: #setUp del state machine
	for child in get_children(): 
		if child is State:
			states[normalize_state_name(child.name)] = child
			child.Transitioned.connect(on_child_transition)
	
	if initial_state: 
		initial_state.enter()
		current_state = initial_state
		
func normalize_state_name(state_name:String) -> String:
	return state_name.to_lower()
		
func set_state(new_state: String):
	if states.has(normalize_state_name(new_state)):
		on_child_transition(current_state, new_state)
	else: 
		print("unrecognized state to set: " +  str(new_state))

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
		
	
