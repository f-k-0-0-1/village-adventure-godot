extends CharacterBody2D

@export var speed: float = 130.0
@export var gravity: float = 800.0  
@export var jump_force: float = -320.0  

# The Y coordinate threshold where the player is considered "fallen" out of bounds
@export var fall_threshold_y: float = 400.0 

# Fallback respawn position if no marker is found in the scene
@export var default_respawn_position: Vector2 = Vector2(100, 150)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer  # Reference to AnimationPlayer

var joystick_node: Node = null
var spawn_position: Vector2

# State flags to manage custom actions (like fishing, attacking, or getting hurt)
var is_fishing: bool = false
var is_dead: bool = false

func _ready() -> void:
	play_animation("idle")
	
	# 1. Automatically find the virtual joystick in the scene tree using its group name
	var joysticks = get_tree().get_nodes_in_group("joystick")
	if joysticks.size() > 0:
		joystick_node = joysticks[0]
	
	# 2. Determine spawn position from a Marker2D in the scene if available
	var spawn_marker = get_parent().get_node_or_null("PlayerSpawnPoint")
	if spawn_marker and spawn_marker is Node2D:
		spawn_position = spawn_marker.global_position
	else:
		spawn_position = default_respawn_position

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# If fishing or attacking, lock horizontal motion but keep gravity active if airborne
	if is_fishing:
		velocity.x = 0.0
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return

	# 1. Apply gravity if airborne
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Handle Jump input (using dedicated "jump" action map)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# 3. Handle Attack input (using dedicated "attack" action map)
	if Input.is_action_just_pressed("attack") and is_on_floor():
		trigger_attack()
		return

	# 4. Get horizontal input direction from keyboard using "move_left" and "move_right"
	var horizontal_input := Input.get_axis("move_left", "move_right")

	# 5. Override or combine with virtual joystick horizontal movement if active
	if joystick_node and "joystick_dir" in joystick_node:
		var joy_dir: Vector2 = joystick_node.joystick_dir
		if abs(joy_dir.x) > 0.1:
			horizontal_input = joy_dir.x

	velocity.x = horizontal_input * speed

	# 6. Handle Sprite Direction Flipping
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

	# 7. Handle Animation States
	update_animations()

	# 8. Check if player has fallen past the fall threshold Y coordinate
	if global_position.y > fall_threshold_y:
		respawn_player()

	# 9. Move and slide against world collision layers
	move_and_slide()

func update_animations() -> void:
	if is_dead or is_fishing:
		return

	if not is_on_floor():
		play_animation("idle") 
	elif velocity.x != 0:
		play_animation("walk")
	else:
		play_animation("idle")

func play_animation(anim_name: String) -> void:
	if sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)

# --- Direct Fishing Action using AnimationPlayer ---

func start_fishing_action() -> void:
	if is_fishing or not is_on_floor():
		return # Can only fish while safely standing on the floor/dock
	
	is_fishing = true
	velocity = Vector2.ZERO
	
	print("Started fishing...")
	sprite.play("fishing")
	
	# Play custom AnimationPlayer track for fishing start
	if anim_player and anim_player.has_animation("fishing_start"):
		anim_player.play("fishing_start")
	
	# Wait for a 3-second catch timer
	await get_tree().create_timer(3.0).timeout
	
	# Trigger the fishing end animation sequence in place of hook
	sprite.play("hook") # Or keep sprite matching if desired
	if anim_player and anim_player.has_animation("fishing_end"):
		anim_player.play("fishing_end")
		
	print("Caught a fish successfully!")
	
	# Wait for the animation player to finish the fishing_end track before restoring normal control
	if anim_player and anim_player.has_animation("fishing_end"):
		await anim_player.animation_finished
	else:
		await sprite.animation_finished
		
	is_fishing = false
	sprite.play("idle")
	
	if anim_player and anim_player.has_animation("RESET"):
		anim_player.play("RESET")

# --- Other Action Triggers ---

func trigger_attack() -> void:
	is_fishing = true # Lock movement during attack
	velocity = Vector2.ZERO
	sprite.play("attack")
	if anim_player and anim_player.has_animation("attack"):
		anim_player.play("attack")
		
	await sprite.animation_finished
	is_fishing = false

func trigger_hurt() -> void:
	sprite.play("hurt")

func trigger_death() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	if anim_player:
		anim_player.stop()
	sprite.play("death")
	await sprite.animation_finished
	respawn_player()
	is_dead = false

func respawn_player() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	is_dead = false
	is_fishing = false
	if anim_player and anim_player.has_animation("RESET"):
		anim_player.play("RESET")
	play_animation("idle")
	print("Player fell! Respawning at: ", spawn_position)
