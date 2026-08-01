extends CanvasLayer

signal joystick_moved(direction: Vector2)

@export var max_distance: float = 50.0  # Maximum pixel radius the tip can move from the base

@onready var left_touch_zone: Control = $LeftTouchZone
@onready var base: Control = $LeftTouchZone/Base
@onready var tip: Control = $LeftTouchZone/Base/Tip

var touch_index: int = -1  # Tracks active touch/mouse input index (-1 means not pressed)
var joystick_dir: Vector2 = Vector2.ZERO  # Public variable read by the player script
var base_global_pos: Vector2

func _ready() -> void:
	# Ensure the touch zone can receive mouse/touch input across the screen or its area
	left_touch_zone.mouse_filter = Control.MOUSE_FILTER_STOP

func _input(event: InputEvent) -> void:
	# Use _input instead of _gui_input to reliably catch touch/mouse drags anywhere on mobile/PC
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			# Check if touch/click is inside the LeftTouchZone rect
			if left_touch_zone.get_global_rect().has_point(event.position):
				if touch_index == -1:
					touch_index = event.index if event is InputEventScreenTouch else 0
					update_joystick(event.position)
		else:
			if touch_index == (event.index if event is InputEventScreenTouch else 0):
				reset_joystick()

	elif event is InputEventScreenDrag or event is InputEventMouseMotion:
		if touch_index == (event.index if event is InputEventScreenDrag else 0):
			update_joystick(event.position)

func update_joystick(touch_pos: Vector2) -> void:
	# Get the center position of the base in global coordinates
	var base_center = base.global_position + (base.size / 2.0)
	var diff = touch_pos - base_center
	var distance = diff.length()
	
	if distance > max_distance:
		diff = diff.normalized() * max_distance
		tip.global_position = base_center + diff - (tip.size / 2.0)
	else:
		tip.global_position = touch_pos - (tip.size / 2.0)

	# Calculate normalized direction vector (-1 to 1) and store it
	joystick_dir = diff / max_distance
	emit_signal("joystick_moved", joystick_dir)

func reset_joystick() -> void:
	touch_index = -1
	joystick_dir = Vector2.ZERO
	# Snap the tip back to the center of the base
	var base_center = base.global_position + (base.size / 2.0)
	tip.global_position = base_center - (tip.size / 2.0)
	emit_signal("joystick_moved", Vector2.ZERO)
