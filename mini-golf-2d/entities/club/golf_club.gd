@tool
class_name GolfClub
extends Node2D


signal swing_started
signal swing_ended

@export var ball: GolfBall
@export_range(0.0, 100.0, 0.1) var strength := 10.0

@onready var shot_area: DragThrowArea2D = $ShotArea
@onready var club: Sprite2D = $Club
@onready var swing_direction: Sprite2D = $SwingDirection
@onready var club_offset_x := club.offset.x

var is_swinging := false


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if is_swinging:	
		var magnitude := shot_area.get_drag_baked_length()
		swing_direction.rotation = shot_area.drag.angle()
		swing_direction.scale.x = remap(magnitude, 0, 1, 1, 5)
		club.offset.x = club_offset_x * remap(magnitude, 0, 1, 0.7, 2)
		if shot_area.should_invert():
			club.offset.x *= -1
			club.flip_h = true
		else:
			club.flip_h = false
		
		swing_direction.visible = true if shot_area.drag else false


func _on_shot_area_grabbed() -> void:
	is_swinging = true
	swing_started.emit()
	
	club.visible = true


func _on_shot_area_released(cancelled: bool) -> void:
	is_swinging = false
	swing_ended.emit()
	if ball and not cancelled:
		ball.apply_central_impulse(shot_area.drag * strength)
	
	club.visible = false
	swing_direction.visible = false
