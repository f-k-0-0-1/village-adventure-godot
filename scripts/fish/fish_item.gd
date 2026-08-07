class_name FishItem
extends Resource

@export var fish_name: String = "Common Fish"
@export var fish_texture: Texture2D
@export var minigame_difficulty: float = 1.0  # Speed/tension intensity
@export var sell_value: int = 10
@export_enum("Common", "Rare", "Legendary") var rarity: int = 0
