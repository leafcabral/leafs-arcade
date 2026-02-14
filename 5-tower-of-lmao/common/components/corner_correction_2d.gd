@tool
@icon("res://common/components/corner_correction_2d.png")
class_name CornerCorrection2D
extends Node2D


signal corner_corrected

const CC_LEFT_NAME := ^"LeftRay"
const CC_MIDDLE_NAME := ^"MiddleShape"
const CC_RIGHT_NAME := ^"RightRay"

@export_range(0, 32, 0.01, "or_greater") var amount := 16.0:
	set(value):
		amount = value
		update_corner_correction_properties()
@export_range(0, 128, 0.1, "or_greater") var length := 32.0:
	set(value):
		length = value
		update_corner_correction_properties()
@export_range(0, 100, 0.01, "or_greater") var distance_between := 64.0:
	set(value):
		distance_between = value
		update_corner_correction_properties()
@export_tool_button("Reload Rays and Shape", "Reload") var reload_button = update_corner_correction_properties

var left_ray: RayCast2D
var middle_shape: ShapeCast2D
var right_ray: RayCast2D

@onready var parent := get_parent() as CharacterBody2D


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		parent = get_parent()
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not parent is CharacterBody2D:
		warnings.append(
			"CornerCorrectionComponent only serves to provide correct the position of CharacterBody2D derived node.
			Please, only use it as a child of CharacterBody2D to make it work."
		)
		
	return warnings


func _ready() -> void:
	_setup_corner_correction_nodes()


func _process(_delta: float) -> void:
	if parent.velocity.y < 0 and not middle_shape.is_colliding():
		try_corner_correction()


func update_corner_correction_properties() -> void:
	if not (left_ray and right_ray and middle_shape):
		return
	
	var half_distance := distance_between / 2
	var rays: Array[RayCast2D] = [left_ray, right_ray]
	for i in 2:
		rays[i].position.x = half_distance * [-1, 1][i]
		rays[i].target_position.y = -length
	
	var middle := middle_shape
	middle.position.y = - length / 2
	middle.target_position = Vector2.ZERO
	middle.shape.size.x = maxf(0, distance_between - 2 * amount)
	middle.shape.size.y = length


func try_corner_correction() -> void:
	var left_colliding := left_ray.is_colliding()
	var right_colliding := right_ray.is_colliding()
	
	if left_colliding and not right_colliding and parent.velocity.x >= 0:
		parent.position.x += amount
		corner_corrected.emit()
	elif not left_colliding and right_colliding and parent.velocity.x <= 0:
		parent.position.x -= amount
		corner_corrected.emit()


func _setup_corner_correction_nodes() -> void:
	left_ray = get_node_or_null(CC_LEFT_NAME)
	middle_shape = get_node_or_null(CC_MIDDLE_NAME)
	right_ray = get_node_or_null(CC_RIGHT_NAME)
	
	if not left_ray:
		left_ray = _create_ray_cast(CC_LEFT_NAME)
		add_child(left_ray)
	if not middle_shape:
		middle_shape = _create_shape_cast(CC_MIDDLE_NAME)
		add_child(middle_shape)
	if not right_ray:
		right_ray = _create_ray_cast(CC_RIGHT_NAME)
		add_child(right_ray)
	
	update_corner_correction_properties()


func _create_ray_cast(node_name: String) -> RayCast2D:
	var raycast := RayCast2D.new()
	raycast.name = node_name
	raycast.collision_mask = parent.collision_mask
	return raycast


func _create_shape_cast(node_name: String) -> ShapeCast2D:
	var shape_cast := ShapeCast2D.new()
	shape_cast.name = node_name
	shape_cast.shape = RectangleShape2D.new()
	shape_cast.collision_mask = parent.collision_mask
	return shape_cast
