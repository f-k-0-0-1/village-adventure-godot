extends Area2D

@export var prompt_message: String = "Press Fishing Button"

var player_in_range: bool = false
var player_node: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		player_node = body
		print("Player entered the fishing zone!")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		player_node = null
		print("Player left the fishing zone.")

func _unhandled_input(event: InputEvent) -> void:
	# Trigger fishing directly using your new "fishing" input action
	if player_in_range and event.is_action_pressed("fishing"):
		if player_node and player_node.has_method("start_fishing_action"):
			player_node.start_fishing_action()
