extends CharacterBody2D

const SPEED := 240.0
const JUMP_VELOCITY := -450.0
const GRAVITY := 1050.0
const SHOOT_COOLDOWN := 0.22

const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const FIRST_STAGE := "res://scenes/stages/stage_01.tscn"

var _anim_t := 0.0
var _shoot_cd := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var weapon: Node2D = $Weapon
@onready var muzzle: Marker2D = $Weapon/Muzzle

func _ready() -> void:
	add_to_group(&"player")
	var path := ProjectSettings.globalize_path("res://assets/characters/lampiao_maria_sheet.png")
	var img := Image.load_from_file(path)
	if img != null:
		var tex := ImageTexture.create_from_image(img)
		sprite.texture = tex
		sprite.hframes = 8
		sprite.vframes = 1
		sprite.frame = 0


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var dir := Input.get_axis(&"move_left", &"move_right")
	velocity.x = dir * SPEED

	move_and_slide()

	_anim_t += delta
	if sprite.texture:
		sprite.flip_h = velocity.x < -12.0
		if absf(velocity.x) > 12.0:
			sprite.frame = 2 + (int(_anim_t * 7.0) % 2)
		else:
			sprite.frame = 0 + (int(_anim_t * 3.5) % 2)

	weapon.scale.x = -1.0 if sprite.flip_h else 1.0

	if _shoot_cd > 0.0:
		_shoot_cd -= delta
	if Input.is_action_pressed(&"shoot") and _shoot_cd <= 0.0:
		_shoot_cd = SHOOT_COOLDOWN
		_fire_bullet()


func _fire_bullet() -> void:
	var facing := Vector2.LEFT if sprite.flip_h else Vector2.RIGHT
	var b: CharacterBody2D = BULLET_SCENE.instantiate()
	b.direction = facing
	b.global_rotation = facing.angle()
	b.global_position = muzzle.global_position + facing * 10.0
	var parent_node := get_parent()
	if parent_node:
		parent_node.add_child(b)


func reset_to_spawn() -> void:
	get_tree().change_scene_to_file(FIRST_STAGE)
