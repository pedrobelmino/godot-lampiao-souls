extends CharacterBody2D

var direction: Vector2 = Vector2.RIGHT

const SPEED := 340.0
const MAX_TRAVEL := 1500.0

var _traveled: float = 0.0


func _physics_process(delta: float) -> void:
	var step := direction * SPEED * delta
	_traveled += step.length()
	velocity = direction * SPEED
	move_and_slide()

	var hit_player := false
	for i in get_slide_collision_count():
		var collider := get_slide_collision(i).get_collider()
		if collider is Node and collider.is_in_group(&"player"):
			hit_player = true
			if collider.has_method(&"reset_to_spawn"):
				collider.reset_to_spawn()
			break
	if hit_player:
		queue_free()
		return
	if get_slide_collision_count() > 0:
		queue_free()
		return
	if _traveled >= MAX_TRAVEL:
		queue_free()
