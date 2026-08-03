extends CanvasLayer

signal transition_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	# Ensure it starts completely invisible and doesn't block inputs
	visible = false
	color_rect.modulate.a = 0.0

func play_enter_transition() -> void:
	visible = true
	animation_player.play("fade_to_clouds")
	await animation_player.animation_finished
	emit_signal("transition_finished")

func play_exit_transition() -> void:
	visible = true
	animation_player.play("fade_to_game")
	await animation_player.animation_finished
	visible = false # Hide it completely so it never blocks clicks again
