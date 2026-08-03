extends CharacterBody2D

@export var speed: float = 120.0
@export var gravity: float = 800.0  
@export var jump_force: float = -300.0  

# The Y coordinate threshold where the player is considered "fallen" out of bounds
@export var fall_threshold_y: float = 400.0 

# Fallback respawn position if no marker is found in the scene
@export var default_respawn_position: Vector2 = Vector2(100, 150)

# Reference to hold our virtual joystick node dynamically
var joystick_node: Node = null
var spawn_position: Vector2

func _ready() -> void:
	# 1. Automatically find the joystick in the scene tree using its group name
	var joysticks = get_tree().get_nodes_in_group("joystick")
	if joysticks.size() > 0:
		joystick_node = joysticks[0]
	
	# 2. Determine the spawn position on load
	var spawn_marker = get_parent().get_node_or_null("PlayerSpawnPoint")
	if spawn_marker and spawn_marker is Node2D:
		spawn_position = spawn_marker.global_position
	else:
		spawn_position = default_respawn_position

func _physics_process(delta: float) -> void:
	# 1. Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Get horizontal input direction from keyboard (A/D or Left/Right arrows)
	var horizontal_input := Input.get_axis("ui_left", "ui_right")
	
	# 3. Override or combine with virtual joystick horizontal movement if active
	if joystick_node and "joystick_dir" in joystick_node:
		var joy_dir: Vector2 = joystick_node.joystick_dir
		if abs(joy_dir.x) > 0.1:
			horizontal_input = joy_dir.x

	# 4. Apply horizontal velocity
	velocity.x = horizontal_input * speed

	# 5. Check if player has fallen past the fall threshold Y coordinate
	if global_position.y > fall_threshold_y:
		respawn_player()

	# 6. Move and slide
	move_and_slide()

func respawn_player() -> void:
	# Teleport back to spawn position and reset all momentum
	global_position = spawn_position
	velocity = Vector2.ZERO
	print("Player fell! Respawning at: ", spawn_position)
