extends CharacterBody2D

@export var speed: float = 120.0

func _physics_process(_delta: float) -> void:
	# Get vector input from WASD or Arrow keys
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_dir != Vector2.ZERO:
		velocity = input_dir * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	move_and_slide()
