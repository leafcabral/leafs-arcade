class_name Player
extends Node2D


const SLICE_RADIUS := 5.0

var slice_points := PackedVector2Array()
@onready var delete_slice_point_delay: Timer = $DeleteSlicePointDelay


func _process(_delta: float) -> void:
	var mouse_position := get_local_mouse_position()
	
	if Input.is_action_just_pressed("slice"):
		slice_points.clear()
		slice_points.append(mouse_position)
		delete_slice_point_delay.start()
		
	elif Input.is_action_pressed("slice"):
		if not slice_points.is_empty():
			var distance_to_last := mouse_position.distance_to(slice_points[-1])
			if distance_to_last > SLICE_RADIUS:
				slice_points.append(mouse_position)
		else:
			slice_points.append(mouse_position)
		
		if len(slice_points) < 2 and delete_slice_point_delay.is_stopped():
			delete_slice_point_delay.start()
		
	if delete_slice_point_delay.is_stopped() and not slice_points.is_empty():
		await get_tree().create_timer(0.05).timeout
		slice_points.remove_at(0)
		
		#slice_start = slice_start.move_toward(slice_end, 300 * delta)
	queue_redraw()


func _draw() -> void:
	if len(slice_points) >= 2:
		draw_polyline(slice_points, Color.WHITE, SLICE_RADIUS * 2, true)
	elif len(slice_points) == 1:
		draw_circle(slice_points[0], SLICE_RADIUS, Color.WHITE)
