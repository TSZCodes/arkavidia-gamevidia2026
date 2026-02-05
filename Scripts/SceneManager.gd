extends Node

var path_history : Array[String] = []

var overlays: Array[Node] = []

func change_scene(new_scene_path: String, track: bool = true) -> void:
	if track and get_tree().current_scene:
		var current_scene := get_tree().current_scene.scene_file_path
		path_history.append(current_scene)
	get_tree().change_scene_to_file(new_scene_path)
	clear_overlays()

func overlay_scene(new_scene_path: String) -> void:
	var overlay: Node = load(new_scene_path).instantiate()
	overlays.append(overlay)
	get_tree().root.add_child(overlay)

func unoverlay_scene() -> void:
	if overlays.is_empty():
		return
	var overlay: Node = overlays.pop_back()
	overlay.get_parent().remove_child(overlay)
	overlay.queue_free()

func can_unoverlay() -> bool:
	return not overlays.is_empty()

func go_back() -> void:
	if not path_history.is_empty():
		var previous_scene_path = path_history.pop_back()
		get_tree().change_scene_to_file(previous_scene_path)
	clear_overlays()

func clear_overlays() -> void:
	for overlay in overlays:
		overlay.queue_free()
	overlays.clear()

func restart_scene() -> void:
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)
	pass
