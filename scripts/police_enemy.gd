extends CharacterBody2D

enum WeaponMode { BATON, GUN }

const MOVE_SPEED := 52.0
const GRAVITY := 1050.0
## Mais alto que antes (~-400) para atravessar buracos típicos de 1–2 tiles sem cair.
const JUMP_VELOCITY := -535.0
const WALL_PROBE_LEN := 44.0
const FLOOR_PROBE_LEN := 48.0
const JUMP_COOLDOWN := 0.32
const BATON_SWING_AMP := 0.42
const SHOOT_COOLDOWN := 1.15
const SHOOT_DELAY_START := 0.55

const ENEMY_BULLET_SCENE := preload("res://scenes/enemy_bullet.tscn")

@export var weapon_mode: WeaponMode = WeaponMode.BATON

@onready var _visual: Node2D = $Visual
@onready var _baton: Node2D = $Visual/Baton
@onready var _gun: Node2D = $Visual/Gun
@onready var _muzzle: Marker2D = $Visual/Gun/Muzzle
@onready var _wall_probe: RayCast2D = $WallProbe
@onready var _floor_probe: RayCast2D = $FloorProbe
@onready var _body_collision: CollisionShape2D = $CollisionShape2D

## Retângulo de colisão do corpo (não usa Visual / arma).
var _body_half_width: float = 9.0
var _body_floor_y: float = 0.0
var _body_mid_y: float = -14.0

var _anim_t := 0.0
var _jump_cd := 0.0
var _shoot_cd := 0.0


func _ready() -> void:
	velocity = Vector2.ZERO
	add_to_group(&"enemy")
	var hb := get_node_or_null(^"Hurtbox") as Area2D
	if hb:
		hb.body_entered.connect(_on_hurtbox_body_entered)
	if weapon_mode == WeaponMode.GUN:
		if _baton:
			_baton.visible = false
		if _gun:
			_gun.visible = true
		_shoot_cd = SHOOT_DELAY_START
	else:
		if _baton:
			_baton.visible = true
		if _gun:
			_gun.visible = false

	_init_body_probe_offsets()


func _init_body_probe_offsets() -> void:
	if _body_collision and _body_collision.shape is RectangleShape2D:
		var rect := _body_collision.shape as RectangleShape2D
		_body_half_width = rect.size.x * 0.5
		_body_floor_y = _body_collision.position.y + rect.size.y * 0.5
		_body_mid_y = _body_collision.position.y


func _physics_process(delta: float) -> void:
	if _jump_cd > 0.0:
		_jump_cd -= delta

	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	var dir := 0.0
	if player:
		var dx := player.global_position.x - global_position.x
		dir = signf(dx)
		velocity.x = dir * MOVE_SPEED
		if _visual:
			_visual.scale.x = -1.0 if dx < 0.0 else 1.0
	else:
		velocity.x = 0.0

	if is_on_floor() and dir != 0.0 and _jump_cd <= 0.0:
		var should_jump := false
		var front_x := dir * _body_half_width
		if _wall_probe:
			_wall_probe.position = Vector2(front_x, _body_mid_y)
			_wall_probe.target_position = Vector2(dir * WALL_PROBE_LEN, 0.0)
			_wall_probe.force_raycast_update()
			if _wall_probe.is_colliding():
				should_jump = true
		if _floor_probe:
			_floor_probe.position = Vector2(front_x, _body_floor_y)
			_floor_probe.target_position = Vector2(0.0, FLOOR_PROBE_LEN)
			_floor_probe.force_raycast_update()
			if not _floor_probe.is_colliding():
				should_jump = true
		if should_jump:
			velocity.y = JUMP_VELOCITY
			_jump_cd = JUMP_COOLDOWN

	velocity.y += GRAVITY * delta
	move_and_slide()

	_anim_t += delta
	if weapon_mode == WeaponMode.BATON and _baton:
		_baton.rotation = sin(_anim_t * 6.5) * BATON_SWING_AMP
	elif weapon_mode == WeaponMode.GUN:
		if _gun:
			_gun.rotation = sin(_anim_t * 5.0) * 0.08
		if player and _muzzle and is_on_floor():
			if _shoot_cd > 0.0:
				_shoot_cd -= delta
			if _shoot_cd <= 0.0:
				_shoot_cd = SHOOT_COOLDOWN
				_fire_at_player(player)


func _fire_at_player(player: Node2D) -> void:
	var ga := get_node_or_null("/root/GameAudio")
	if ga and ga.has_method(&"play_shoot"):
		ga.play_shoot()
	if not _muzzle:
		return
	var dx := player.global_position.x - _muzzle.global_position.x
	if absf(dx) < 2.0:
		return
	var aim := Vector2(signf(dx), 0.0)
	var b: CharacterBody2D = ENEMY_BULLET_SCENE.instantiate()
	b.direction = aim
	b.global_position = _muzzle.global_position
	var parent_node := get_parent()
	if parent_node:
		parent_node.add_child(b)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"player"):
		return
	if body.has_method(&"reset_to_spawn"):
		body.reset_to_spawn()
