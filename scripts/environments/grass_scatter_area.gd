@tool
class_name GrassScatterArea
extends Node2D

@export var grass_scene: PackedScene = preload("res://scenes/environments/grass_tuft.tscn")
@export var scatter_area: Rect2 = Rect2(Vector2.ZERO, Vector2(400, 300))
@export var density: int = 50

@export var generate_grass: bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			_clear_old_grass()
			_scatter_grass()
		generate_grass = false

var grass_texture_array: Array[Texture2D] = [
	preload("res://assets/village_tilesets/2 Objects/5 Grass/1.png"),
	preload("res://assets/village_tilesets/2 Objects/5 Grass/2.png"),
	preload("res://assets/village_tilesets/2 Objects/5 Grass/3.png"),
	preload("res://assets/village_tilesets/2 Objects/5 Grass/4.png"),
	preload("res://assets/village_tilesets/2 Objects/5 Grass/5.png"),
	preload("res://assets/village_tilesets/2 Objects/5 Grass/6.png")
]

func _ready() -> void:
	if not Engine.is_editor_hint():
		# Automatically generate grass at runtime matching the editor layout
		_clear_old_grass()
		_scatter_grass()

func _scatter_grass() -> void:
	if not grass_scene:
		printerr("Grass Scene not assigned!")
		return
		
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(density):
		var tuft = grass_scene.instantiate() as Sprite2D
		if tuft:
			add_child(tuft)
			if Engine.is_editor_hint():
				tuft.owner = self 
			
			tuft.setup(grass_texture_array)
			
			# Ensure random coordinates map strictly within the Rect2 local bounds
			var random_x = rng.randf_range(scatter_area.position.x, scatter_area.position.x + scatter_area.size.x)
			var random_y = rng.randf_range(scatter_area.position.y, scatter_area.position.y + scatter_area.size.y)
			tuft.position = Vector2(random_x, random_y)

func _clear_old_grass() -> void:
	var children_to_delete = []
	for child in get_children():
		children_to_delete.append(child)
	
	for child in children_to_delete:
		if Engine.is_editor_hint():
			child.free()
		else:
			child.queue_free()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(scatter_area, Color(0.2, 0.8, 0.2, 0.3), true)
		draw_rect(scatter_area, Color(0.1, 0.5, 0.1, 0.8), false)
