@tool
extends Sprite2D

@export var grass_textures: Array[Texture2D] = []

func setup(textures: Array[Texture2D]) -> void:
	grass_textures = textures
	if grass_textures.size() > 0:
		texture = grass_textures[randi() % grass_textures.size()]
		scale.x = 1.0 if randf() > 0.5 else -1.0
		scale.y = randf_range(0.85, 1.15)

func _ready() -> void:
	if texture == null and grass_textures.size() > 0:
		setup(grass_textures)
