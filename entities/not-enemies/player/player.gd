extends CharacterBody2D

@export var ACCELERATION: float = 3750.0 
@export var H_SPEED_LIMIT: float = 600.0
@export var jump_speed: int = 500
@export var FRICTION_WEIGHT: float = 6.25 
@export var gravity: int = 625.0 

var h_movement_direction: int = 0
var jump: bool = false

func _physics_process(delta: float) -> void:
	#Hace la accion con algun input
	get_input()
	
	## Si se mueve a la izquierda (h_movement_direction == -1) o 
	## a la derecha (h_movement_direction == 1) acelera, si no se mueve 
	## a ninguna dirección desacelera.
	if h_movement_direction != 0:
		
		## Si se mueve a alguna dirección se calcula la aceleración
		## con respecto a su posicion horizontal (velocity.x + (h_movement_direction * ACCELERATION * delta))
		## y con la funcion clamp se busca que no se pase del limite de velocidad minimo o maximo.
		
		## Si el calculo es mayor a H_SPEED_LIMIT entonces velocity.x es H_SPEED_LIMIT, 
		## Si el calculo es menor a -H_SPEED_LIMIT entonces velocity.x es -H_SPEED_LIMIT,
		## Si el calculo no supera ninguno de los limites entonces velocity.x es velocity.x + (h_movement_direction * ACCELERATION * delta)
		
		velocity.x = clamp(
			velocity.x + (h_movement_direction * ACCELERATION * delta),
			-H_SPEED_LIMIT,
			H_SPEED_LIMIT
		)
	else:
		
		## Si no se mueve a ningun lado desacelera de forma suave gracias a la
		## funcion lerp. 
		
		## Con la funcion lerp podemos reducir un valor "velocity.x" a 0.0. 
		## La velocidad con la cual se reduce depende de "FRICTION_WEIGHT * delta"
		velocity.x = lerp(velocity.x, 0.0, FRICTION_WEIGHT * delta) if abs(velocity.x) > 1 else 0
	
	# Jump
	## Si se pulso el input para saltar y esta en el piso
	## subí en el eje y. 
	if jump and is_on_floor():
		velocity.y -= jump_speed #Velocidad de salto. 
	
	# Gravity
	## Calculo en el eje y para la gravedad del jugador
	velocity.y += gravity * delta
	
	## Cuando se tienen aplican todos los cambio, surte efecto 
	## en el jugador. 
	move_and_slide() 

func get_input() -> void:
	# Jump Action
	jump = Input.is_action_just_pressed("jump") #Si salta es true

	#horizontal speed
	# Si se mueve a la izquierda el valor es -1, derecha es 1, no se mueve es 0. 
	h_movement_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left")) 
