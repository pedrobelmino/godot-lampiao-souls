extends CharacterBody2D

const SPEED := 240.0
const JUMP_VELOCITY := -450.0
const GRAVITY := 1050.0
const SHOOT_COOLDOWN := 0.22
const MOVE_THRESHOLD := 12.0
const LEG_WALK_FREQ := 14.0
const HAIR_SWAY_FREQ := 4.5

const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const FIRST_STAGE := "res://scenes/stages/stage_01.tscn"

var _anim_t := 0.0
var _shoot_cd := 0.0
var _facing_left := false

@onready var _visual: Node2D = $Visual
@onready var _hair_strand_l: Node2D = $Visual/HairStrandL
@onready var _hair_strand_r: Node2D = $Visual/HairStrandR
@onready var _hair_tip: Node2D = $Visual/HairTip
@onready var _leg_l: Node2D = $Visual/LegL
@onready var _leg_r: Node2D = $Visual/LegR
@onready var weapon: Node2D = $Weapon
@onready var muzzle: Marker2D = $Weapon/Muzzle


func _ready() -> void:
	add_to_group(&"player")


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var dir := Input.get_axis(&"move_left", &"move_right")
	velocity.x = dir * SPEED

	move_and_slide()

	var moving := absf(velocity.x) > MOVE_THRESHOLD
	if moving:
		_facing_left = velocity.x < 0.0

	_anim_t += delta

	if _visual:
		_visual.scale.x = -1.0 if _facing_left else 1.0

	var walk_phase := _anim_t * LEG_WALK_FREQ
	if moving:
		_leg_l.rotation = sin(walk_phase) * 0.38
		_leg_r.rotation = -sin(walk_phase) * 0.38
	else:
		_leg_l.rotation = 0.0
		_leg_r.rotation = 0.0

	var hair_amp := 0.14 if moving else 0.07
	if _hair_strand_l:
		_hair_strand_l.rotation = sin(_anim_t * HAIR_SWAY_FREQ) * hair_amp
	if _hair_strand_r:
		_hair_strand_r.rotation = -sin(_anim_t * HAIR_SWAY_FREQ + 0.8) * hair_amp
	if _hair_tip:
		_hair_tip.rotation = sin(_anim_t * (HAIR_SWAY_FREQ * 0.6)) * (hair_amp * 0.85)

	weapon.scale.x = -1.0 if _facing_left else 1.0

	if _shoot_cd > 0.0:
		_shoot_cd -= delta
	if Input.is_action_pressed(&"shoot") and _shoot_cd <= 0.0:
		_shoot_cd = SHOOT_COOLDOWN
		_fire_bullet()


func _fire_bullet() -> void:
	var facing := Vector2.LEFT if _facing_left else Vector2.RIGHT
	var b: CharacterBody2D = BULLET_SCENE.instantiate()
	b.direction = facing
	b.global_rotation = facing.angle()
	b.global_position = muzzle.global_position + facing * 10.0
	var parent_node := get_parent()
	if parent_node:
		parent_node.add_child(b)


func reset_to_spawn() -> void:
	get_tree().change_scene_to_file(FIRST_STAGE)
