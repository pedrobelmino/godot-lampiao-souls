extends Control

@export_file("*.tscn") var first_stage: String = "res://scenes/stages/stage_01.tscn"

@onready var _content_root: Control = $ContentRoot
@onready var _logo: TextureRect = $ContentRoot/CenterBlock/Column/Logo

func _ready() -> void:
	var lp := ProjectSettings.globalize_path("res://assets/ui/bellapps_logo.png")
	var img := Image.load_from_file(lp)
	if img != null:
		_logo.texture = ImageTexture.create_from_image(img)
	_content_root.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_content_root, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _on_play_pressed() -> void:
	if first_stage.is_empty():
		return
	get_tree().change_scene_to_file(first_stage)
