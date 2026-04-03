extends CharacterBody2D

const SPEED := 240.0
const CROUCH_SPEED_MULT := 0.52
const JUMP_VELOCITY := -450.0
const GRAVITY := 1050.0
const SHOOT_COOLDOWN := 0.22
const MOVE_THRESHOLD := 12.0

const STAND_BODY_SIZE := Vector2(16, 28)
const CROUCH_BODY_SIZE := Vector2(16, 16)
const STAND_COLLISION_Y := -14.0
const CROUCH_COLLISION_Y := -8.0
const STAND_SPRITE_POS := Vector2(0, -18)
const CROUCH_SPRITE_POS := Vector2(0, -12)
const STAND_SPRITE_SCALE_Y := 1.0
const CROUCH_SPRITE_SCALE_Y := 0.7
const STAND_OUTFIT_POS := Vector2(0, -18)
const CROUCH_OUTFIT_POS := Vector2(0, -12)
const STAND_WEAPON_POS := Vector2(0, -16)
const CROUCH_WEAPON_POS := Vector2(0, -10)

const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const FIRST_STAGE := "res://scenes/stages/stage_01.tscn"

var _anim_t := 0.0
var _shoot_cd := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var _cangaceiro: Node2D = $CangaceiroOutfit
@onready var weapon: Node2D = $Weapon
@onready var muzzle: Marker2D = $Weapon/Muzzle
@onready var _body_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group(&"player")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
	var crouch_move := Input.is_action_pressed(&"move_down") and is_on_floor()
	var move_speed := SPEED * (CROUCH_SPEED_MULT if crouch_move else 1.0)
	velocity.x = dir * move_speed

	move_and_slide()

	var crouch_visual := Input.is_action_pressed(&"move_down") and is_on_floor()
	_apply_crouch(crouch_visual)

	_anim_t += delta
	if sprite.texture:
		var walk_thresh := MOVE_THRESHOLD * 0.48 if crouch_visual else MOVE_THRESHOLD
		sprite.flip_h = velocity.x < -MOVE_THRESHOLD
		var walking := absf(velocity.x) > walk_thresh and is_on_floor()
		if walking:
			sprite.frame = 2 + (int(_anim_t * 7.0) % 2)
		else:
			sprite.frame = 0

	var facing_left := sprite.flip_h
	weapon.scale.x = -1.0 if facing_left else 1.0
	if _cangaceiro:
		_cangaceiro.scale.x = -1.0 if facing_left else 1.0

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


func _apply_crouch(crouching: bool) -> void:
	if _body_shape and _body_shape.shape is RectangleShape2D:
		var rect := _body_shape.shape as RectangleShape2D
		if crouching:
			rect.size = CROUCH_BODY_SIZE
			_body_shape.position.y = CROUCH_COLLISION_Y
		else:
			rect.size = STAND_BODY_SIZE
			_body_shape.position.y = STAND_COLLISION_Y
	if sprite:
		sprite.position = CROUCH_SPRITE_POS if crouching else STAND_SPRITE_POS
		sprite.scale.y = CROUCH_SPRITE_SCALE_Y if crouching else STAND_SPRITE_SCALE_Y
	if _cangaceiro:
		_cangaceiro.position = CROUCH_OUTFIT_POS if crouching else STAND_OUTFIT_POS
		_cangaceiro.scale.y = CROUCH_SPRITE_SCALE_Y if crouching else STAND_SPRITE_SCALE_Y
	if weapon:
		weapon.position = CROUCH_WEAPON_POS if crouching else STAND_WEAPON_POS


func reset_to_spawn() -> void:
	get_tree().change_scene_to_file(FIRST_STAGE)
