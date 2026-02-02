@tool
class_name ClothTrailComponent
extends Line2D


@export_range(2, 100, 1, "or_greater") var num_of_points := 4:
	set(value):
		num_of_points = value
		_update_cloth()
@export_range(0.0, 50.0, 0.01, "suffix:px") var point_spacing := 6.0:
	set(value):
		point_spacing = value
		_update_cloth()
@export_range(1, 5, 0.01, "or_greater") var strech_scale := 1.0
@export_range(0, 1, 0.01) var damping_scale := 0.7
@export_range(0, 10, 0.01, "or_greater") var gravity_strength := 1.0

@export var sprite: Texture2D:
	set = _update_sprite
@export_custom(PROPERTY_HINT_LINK, "") var sprite_scale := Vector2.ONE

var _old_width := 26.0

@onready var _last_global_position := global_position


func _ready() -> void:
	_update_cloth()


func _physics_process(delta: float) -> void:
	var distance := global_position - _last_global_position
	_last_global_position = global_position
	
	apply_gravity(delta)
	apply_swing(distance)


func _draw() -> void:
	if sprite:
		draw_set_transform(Vector2.ZERO, 0.0, sprite_scale)
		var sprite_offset := sprite.get_size() / 2
		
		for i in points:
			draw_texture(sprite, (i / sprite_scale).round() - sprite_offset)
		
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func apply_gravity(delta: float) -> void:
	const gravity := Vector2(0, 150.0)
	for i in range(1, num_of_points):
		set_point_position(i, points[i] + gravity * delta * gravity_strength)


func apply_swing(distance: Vector2) -> void:
	for i in range(1, num_of_points):
		var point_pos := get_point_position(i) - distance * damping_scale
		point_pos = _fix_strech(point_pos, get_point_position(i - 1))
		
		set_point_position(i, point_pos)


func _update_cloth():
	clear_points()
	
	for i in range(num_of_points):
		add_point(Vector2(0, i * point_spacing))


func _update_sprite(new_sprite: Texture2D) -> void:
	sprite = new_sprite
	if sprite:
		_old_width = width
		width = 0
	else:
		width = _old_width
		print(_old_width)


func _fix_strech(point: Vector2, previous_point: Vector2) -> Vector2:
	var point_distance := point.distance_to(previous_point)
	var acceptable_distance := point_spacing * strech_scale
	if point_distance >= acceptable_distance:
		point = point.move_toward(
			previous_point,
			point_distance - acceptable_distance
		)
	
	return point
