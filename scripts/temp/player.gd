extends CharacterBody2D

@export var speed: float = 120.0

# Reference to hold our virtual joystick node dynamically
var joystick_node: Node = null

func _ready() -> void:
	# Automatically find the joystick in the scene tree using its group name
	var joysticks = get_tree().get_nodes_in_group("joystick")
	if joysticks.size() > 0:
		joystick_node = joysticks[0]
	else:
		print("Warning: No virtual joystick found in this scene!")

func _physics_process(_delta: float) -> void:
	# 1. Default to PC keyboard inputs (WASD / Arrows)
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. If a virtual joystick exists and is actively being dragged, override keyboard input
	if joystick_node and "joystick_dir" in joystick_node:
		var joy_dir: Vector2 = joystick_node.joystick_dir
		if joy_dir.length_squared() > 0.0:
			input_dir = joy_dir

	# 3. Apply movement velocity and slide
	velocity = input_dir * speed
	move_and_slide()
