extends CharacterBody2D

const MOVE_SPEED := 52.0
const GRAVITY := 1050.0
const JUMP_VELOCITY := -400.0
const WALL_PROBE_LEN := 44.0
const JUMP_COOLDOWN := 0.38
const BATON_SWING_AMP := 0.42

@onready var _visual: Node2D = $Visual
@onready var _baton: Node2D = $Visual/Baton
@onready var _wall_probe: RayCast2D = $WallProbe

var _anim_t := 0.0
var _jump_cd := 0.0


func _ready() -> void:
	var hb := get_node_or_null(^"Hurtbox") as Area2D
	if hb:
		hb.body_entered.connect(_on_hurtbox_body_entered)


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
	if _baton:
		_baton.rotation = sin(_anim_t * 6.5) * BATON_SWING_AMP


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"player"):
		return
	if body.has_method(&"reset_to_spawn"):
		body.reset_to_spawn()
