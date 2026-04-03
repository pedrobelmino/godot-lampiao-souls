extends Area2D

@export_file("*.tscn") var next_scene: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"player"):
		return
	if next_scene.is_empty():
		return
	get_tree().change_scene_to_file(next_scene)
