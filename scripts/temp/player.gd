extends CharacterBody2D

@export var speed: float = 120.0

func _physics_process(_delta: float) -> void:
	var input_dir := Vector2.ZERO
	
	# Fetch the joystick node using your verified path
	var joystick = get_node_or_null("/root/Village/JoystickControl")
	
	if joystick and "joystick_dir" in joystick and joystick.joystick_dir != Vector2.ZERO:
		input_dir = joystick.joystick_dir
	else:
		# Fallback to keyboard inputs for PC testing
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_dir != Vector2.ZERO:
		velocity = input_dir * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	move_and_slide()
