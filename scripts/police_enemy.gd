extends CharacterBody2D

enum WeaponMode { BATON, GUN }

const MOVE_SPEED := 52.0
const GRAVITY := 1050.0
const JUMP_VELOCITY := -400.0
const WALL_PROBE_LEN := 44.0
const JUMP_COOLDOWN := 0.38
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

var _anim_t := 0.0
var _jump_cd := 0.0
var _shoot_cd := 0.0


func _ready() -> void:
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

	if is_on_floor() and dir != 0.0 and _jump_cd <= 0.0 and _wall_probe:
		_wall_probe.target_position = Vector2(dir * WALL_PROBE_LEN, 0.0)
		_wall_probe.force_raycast_update()
		if _wall_probe.is_colliding():
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
		if player and _muzzle:
			if _shoot_cd > 0.0:
				_shoot_cd -= delta
			if _shoot_cd <= 0.0:
				_shoot_cd = SHOOT_COOLDOWN
				_fire_at_player(player)


func _fire_at_player(player: Node2D) -> void:
	if not _muzzle:
		return
	var to := player.global_position - _muzzle.global_position
	if to.length_squared() < 4.0:
		return
	to = to.normalized()
	var b: CharacterBody2D = ENEMY_BULLET_SCENE.instantiate()
	b.direction = to
	b.global_position = _muzzle.global_position
	var parent_node := get_parent()
	if parent_node:
		parent_node.add_child(b)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"player"):
		return
	if body.has_method(&"reset_to_spawn"):
		body.reset_to_spawn()
