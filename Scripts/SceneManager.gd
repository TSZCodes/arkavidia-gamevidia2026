extends Node

# Scene Manager - Scene Navigation System
# Handles scene switching and navigation history

var current_scene = null
var previous_scene_path: String = ""

func _ready() -> void:
	var root = get_tree().root
	current_scene = get_tree().current_scene
	
	if current_scene == null:
		current_scene = root.get_child(root.get_child_count() - 1)

func switch_scene(res_path: String) -> void:
	call_deferred("_deferred_switch_scene", res_path)

func _deferred_switch_scene(res_path: String) -> void:
	if current_scene:
		previous_scene_path = current_scene.scene_file_path
		current_scene.free()
	
	var s = load(res_path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

func go_back() -> void:
	if previous_scene_path != "":
		switch_scene(previous_scene_path)
	else:
		switch_scene("res://Scenes/main_menu.tscn")
