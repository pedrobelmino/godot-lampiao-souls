extends Control

@export_file("*.tscn") var main_menu_scene: String = "res://scenes/main.tscn"

func _on_play_again_pressed() -> void:
	if main_menu_scene.is_empty():
		return
	get_tree().change_scene_to_file(main_menu_scene)
