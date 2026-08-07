extends Area2D

func _ready() -> void:
	# Safely connect the body_entered signal via code if not connected in the Inspector
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the colliding body is the player using groups or class type
	if body.is_in_group("Player"):
		print("Fishing zone entered! Switching to fishing site...")
		SceneManager.go_to_fishing_site()
