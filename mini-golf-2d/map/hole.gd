@tool
class_name Hole
extends Node2D


signal ball_entered(ball: GolfBall)


func _on_area_inside_body_entered(body: Node2D) -> void:
	if body is GolfBall:
		ball_entered.emit(body)
		print("Uhuul")
