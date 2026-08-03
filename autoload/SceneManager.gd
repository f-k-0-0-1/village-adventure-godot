## SceneManager - Handles all scene transitions and flow (Async Architecture)
extends Node

# Scene constants
const SCENE_SPLASH: String = "res://scenes/ui/Splash_Screen.tscn"
const SCENE_MENU: String = "res://scenes/menus/main_menu.tscn"
const SCENE_LOADING: String = "res://scenes/ui/loading_screen.tscn"
const VILLAGE_SCENE: String = "res://scenes/environments/village.tscn"
const FISHING_SCENE: String = "res://scenes/environments/fishing_site.tscn"

# Cloud Transition Screen Preload (Used for Village <-> Fishing transitions)
const CLOUD_TRANSITION_SCENE = preload("res://scenes/ui/cloud_transition_screen.tscn")
var cloud_transition_instance: Node = null

# Current scene reference
var current_scene: Node = null
var is_transitioning: bool = false

# Holds the path for the loading screen to pick up if using standard loading
var target_level_path: String = "" 

func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
	# Instantiate and persist the cloud transition screen globally
	if not cloud_transition_instance:
		cloud_transition_instance = CLOUD_TRANSITION_SCENE.instantiate()
		root.add_child.bind(cloud_transition_instance).call_deferred()

func load_scene(scene_path: String, use_cloud_transition: bool = false) -> void:
	if is_transitioning:
		print("SceneManager: Already transitioning, ignoring request")
		return
	
	is_transitioning = true
	print("SceneManager: Preparing load for:", scene_path)
	
	# Check if file exists
	if not ResourceLoader.exists(scene_path):
		push_error("SceneManager: Scene not found:", scene_path)
		is_transitioning = false
		return
	
	if use_cloud_transition:
		# --- CLOUD TRANSITION MODE (Acts as the loading screen itself) ---
		
		# 1. Roll in the clouds/fog
		if cloud_transition_instance and cloud_transition_instance.has_method("play_enter_transition"):
			cloud_transition_instance.play_enter_transition()
			await cloud_transition_instance.transition_finished
		
		# 2. Change the scene immediately while hidden behind the clouds
		var error = get_tree().change_scene_to_file(scene_path)
		if error != OK:
			push_error("SceneManager: Failed to change scene:", scene_path)
			is_transitioning = false
			return
		
		await get_tree().process_frame
		current_scene = get_tree().current_scene
		
		# 3. Part the clouds to reveal the new area
		if cloud_transition_instance and cloud_transition_instance.has_method("play_exit_transition"):
			cloud_transition_instance.play_exit_transition()
			
	else:
		# --- STANDARD LOADING SCREEN MODE (Splash / Menu / etc.) ---
		target_level_path = scene_path
		var error = get_tree().change_scene_to_file(SCENE_LOADING)
		
		if error != OK:
			push_error("SceneManager: Failed to load loading screen scene!")
			is_transitioning = false
			return
		
		await get_tree().process_frame
		current_scene = get_tree().current_scene

	is_transitioning = false
	print("SceneManager: Successfully transitioned to:", scene_path)

# --- Standard Flow Transitions (Uses loading_screen.tscn) ---
func go_to_splash() -> void:
	load_scene(SCENE_SPLASH, false)

func go_to_menu() -> void:
	load_scene(SCENE_MENU, false)

# --- Gameplay Flow Transitions (Uses Cloud Transition as Loading Screen) ---
func go_to_village() -> void:
	load_scene(VILLAGE_SCENE, true)

func go_to_fishing_site() -> void:
	load_scene(FISHING_SCENE, true)

func reload_current_scene() -> void:
	if current_scene and current_scene.scene_file_path:
		var use_clouds = current_scene.scene_file_path == FISHING_SCENE or current_scene.scene_file_path == VILLAGE_SCENE
		load_scene(current_scene.scene_file_path, use_clouds)

func quit_game() -> void:
	get_tree().quit()

func get_current_scene_name() -> String:
	if current_scene and current_scene.scene_file_path:
		return current_scene.scene_file_path.get_file().get_basename()
	return "unknown"
