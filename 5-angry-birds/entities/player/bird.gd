extends RigidBody2D


func _on_mouse_flick_finished_holding(direction: Vector2) -> void:
	apply_central_impulse(direction.normalized() * 500)
