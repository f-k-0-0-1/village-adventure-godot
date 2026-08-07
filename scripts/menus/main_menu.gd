extends Control

@export_file("*.tscn") var first_game_scene: String = "res://scenes/environments/fishing_site.tscn"

@onready var play_button: Button = $Button3/MarginContainer/MenuButtons/PlayButton
@onready var option_button: Button = $Button3/MarginContainer/MenuButtons/OptionButton
@onready var quit_button: Button = $Button3/MarginContainer/MenuButtons/QuitButton

@onready var title_label: Label = $MarginContainer/Label
@onready var subtitle_label: Label = $MarginContainer2/Label2

var tween: Tween

func _ready() -> void:
	play_button.grab_focus()
	
	play_button.pressed.connect(_on_play_pressed)
	option_button.pressed.connect(_on_option_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	_setup_button_animations(play_button)
	_setup_button_animations(option_button)
	_setup_button_animations(quit_button)
	
	_play_intro_animations()

func _play_intro_animations() -> void:
	title_label.modulate.a = 0.0
	title_label.position.y -= 10.0
	subtitle_label.modulate.a = 0.0
	subtitle_label.position.y -= -50
	
	play_button.modulate.a = 0.0
	option_button.modulate.a = 0.0
	quit_button.modulate.a = 0.0
	
	var intro_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	intro_tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	intro_tween.tween_property(title_label, "position:y", title_label.position.y + 20, 1.0)
	
	intro_tween.tween_property(subtitle_label, "modulate:a", 1.0, 1.0).set_delay(0.3)
	intro_tween.tween_property(subtitle_label, "position:y", subtitle_label.position.y + 10, 1.0).set_delay(0.3)
	
	intro_tween.tween_property(play_button, "modulate:a", 1.0, 0.8).set_delay(0.6)
	intro_tween.tween_property(option_button, "modulate:a", 1.0, 0.8).set_delay(0.7)
	intro_tween.tween_property(quit_button, "modulate:a", 1.0, 0.8).set_delay(0.8)

func _setup_button_animations(btn: Button) -> void:
	btn.pivot_offset = btn.size / 2.0
	
	btn.mouse_entered.connect(func():
		var hover_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		hover_tween.tween_property(btn, "scale", Vector2(1.08, 1.08), 0.2)
		hover_tween.tween_property(btn, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.2)
	)
	
	btn.mouse_exited.connect(func():
		var exit_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		exit_tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2)
		exit_tween.tween_property(btn, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	)
	
	btn.focus_entered.connect(func():
		var focus_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		focus_tween.tween_property(btn, "scale", Vector2(1.08, 1.08), 0.2)
		focus_tween.tween_property(btn, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.2)
	)
	
	btn.focus_exited.connect(func():
		var unfocus_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		unfocus_tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2)
		unfocus_tween.tween_property(btn, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	)

func _on_play_pressed() -> void:
	_animate_transition_and_load(first_game_scene)

func _on_option_pressed() -> void:
	var click_tween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	click_tween.tween_property(option_button, "scale", Vector2(0.92, 0.92), 0.1)
	click_tween.tween_property(option_button, "scale", Vector2(1.0, 1.0), 0.1)

func _on_quit_pressed() -> void:
	var quit_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	quit_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	quit_tween.tween_callback(get_tree().quit)

func _animate_transition_and_load(target_scene: String) -> void:
	play_button.disabled = true
	option_button.disabled = true
	quit_button.disabled = true
	
	var trans_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	trans_tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 0.6)
	trans_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.6)
	
	await trans_tween.finished
	get_tree().change_scene_to_file(target_scene)
