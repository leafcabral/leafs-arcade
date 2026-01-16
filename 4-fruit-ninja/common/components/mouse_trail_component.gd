class_name MouseTrailComponent
extends Line2D


@export_range(2, 100, 1, "or_greater") var max_points := 32
@export_range(0.0, 50.0, 0.01, "suffix:px") var min_point_spacing := 5.0

@export_group("Vanishing Effect")
@export_range(1, 20, 0.1) var speed_factor := 8.0
@export_range(1, 1000, 0.1) var minimum_speed := 100.0
@export_range(0, 1, 0.01, "or_greater", "suffix:s") var start_delay := 0.15

@export_group("Collision", "collision_")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var collision_enabled := false
@export var collision_node: CollisionObject2D
@export_range(0, 100, 1) var collision_max_lines := 4

@export_group("Show Points", "points_")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var points_enabled := false
@export var points_color := Color.RED
@export_range(0, 10, 0.1, "suffix:px") var points_radius := 5.0


var time_since_trail_start := 0.0

@onready var collision_objects_2d := find_children("*", "CollisionObject2D", false)


func _physics_process(delta: float) -> void:
	var mouse_position := get_local_mouse_position()
	
	if Input.is_action_just_pressed("slice"):
		clear_points()
	elif Input.is_action_pressed("slice"):
		handle_mouse_movement(mouse_position)
	
	if time_since_trail_start >= start_delay:
		remove_trail_points(delta)
	else:
		time_since_trail_start += delta
	
	if collision_enabled and collision_node:
		create_collision_shapes()


func _draw() -> void:
	if points_enabled:
		for i in points:
			draw_circle(i, points_radius, points_color)


func handle_mouse_movement(mouse_position: Vector2) -> void:
	var number_of_points := get_point_count()
	
	if number_of_points >= 1:
		var distance_to_last := mouse_position.distance_to(points[-1])
		if distance_to_last < min_point_spacing:
			return
	else:
		time_since_trail_start = 0.0
	
	add_point(mouse_position)
	if number_of_points + 1 > max_points:
		remove_point(0)
	
	# Workaround for width_curve "glitch" where the line won't show
	# if there are only two points in the line
	if get_point_count() == 2:
		add_point((points[0] + points[1]) / 2)


func remove_trail_points(delta: float) -> void:
	var number_of_points := get_point_count()
	if number_of_points < 2:
		if number_of_points == 1:
			remove_point(0)
		return
	
	var distance_to_remove := get_relative_vanishing_speed() * delta
	while distance_to_remove > 0 and get_point_count() >= 2:
		var a := points[0]
		var b := points[1]
		var segment_length := a.distance_to(b)
		
		if segment_length  <= distance_to_remove:
			remove_point(0)
			distance_to_remove -= segment_length
		else:
			var new_pos := a.move_toward(b,
				distance_to_remove
			)
			set_point_position(0, new_pos)
			distance_to_remove = 0
			return


func get_relative_vanishing_speed() -> float:
	var number_of_points := get_point_count()
	
	var total_trail_length := 0.0
	for i in range(number_of_points - 1):
		total_trail_length += points[i].distance_to(points[i + 1])
	
	return maxf(total_trail_length * speed_factor, minimum_speed)


func create_collision_shapes() -> void:
	for collision_shape in collision_node.get_children():
		collision_shape.queue_free()
	
	if points:
		var num_points_for_collision: int = min(get_point_count(), collision_max_lines + 1)
		for i in range(-1, -num_points_for_collision, -1):
			var segment := SegmentShape2D.new()
			segment.a = points[i]
			segment.b = points[i - 1]
			
			var collision_shape := CollisionShape2D.new()
			collision_shape.shape = segment
			
			collision_node.add_child(collision_shape)
