extends CharacterBody2D

var direction: Vector2 = Vector2.RIGHT

const SPEED := 420.0
const MAX_TRAVEL := 1400.0

var _traveled: float = 0.0


func _physics_process(delta: float) -> void:
	var step := direction * SPEED * delta
	_traveled += step.length()
	velocity = direction * SPEED
	move_and_slide()
	if get_slide_collision_count() > 0:
		for i in get_slide_collision_count():
			var collider := get_slide_collision(i).get_collider()
			if collider is Node and collider.is_in_group(&"enemy"):
				collider.queue_free()
				queue_free()
				return
		queue_free()
		return
	if _traveled >= MAX_TRAVEL:
		queue_free()
