class_name MouseTrailComponent
extends Line2D


@export_range(0.0, 2.5, 0.01, "or_greater", "suffix:s") var fade_start_delay := 0.1
@export_range(0.0, 2.5, 0.01, "or_greater", "suffix:s") var point_fade_delay := 0.0
@export_range(0.0, 10.0, 0.1, "suffix:px") var point_spacing := 5.0

var time_since_trail_start := 0.0
var time_since_last_point := 0.0


func _process(delta: float) -> void:
	var mouse_position := get_local_mouse_position()
	
	if Input.is_action_just_pressed("slice"):
		clear_points()
		time_since_trail_start = 0.0
		
	var number_of_points := get_point_count()
	if Input.is_action_pressed("slice"):
		var can_place_point := true
		
		if number_of_points:
			var distance_to_last := mouse_position.distance_to(points[-1])
			if distance_to_last < point_spacing:
				can_place_point = false
		else:
			time_since_trail_start = 0.0
		
		if can_place_point:
			add_point(mouse_position)
		
		if number_of_points == 2:
			add_point((points[0] + points[1]) / 2)
	
	if number_of_points >= 2:
		if time_since_trail_start >= fade_start_delay:
			if time_since_last_point >= point_fade_delay:
				remove_point(0)
				time_since_last_point = 0.0
			else:
				time_since_last_point += delta
		else:
			time_since_trail_start += delta
