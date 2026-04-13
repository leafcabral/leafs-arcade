@tool
class_name Hole
extends Node2D


const FLAGSTICK_COLLISION_LAYER := 2

signal ball_entered(ball: GolfBall)

@export var flagstick_collision_enabled := false:
	set = set_flagstick_collision_enabled
	
	
@onready var body_flagstick: StaticBody2D = $BodyFlagstick


func _on_area_inside_body_entered(body: Node2D) -> void:
	if body is GolfBall:
		ball_entered.emit(body)
		print("Uhuul")


func set_flagstick_collision_enabled(enabled: bool) -> void:
	flagstick_collision_enabled = enabled
	if body_flagstick:
		body_flagstick.collision_layer = FLAGSTICK_COLLISION_LAYER if flagstick_collision_enabled else 0
	
