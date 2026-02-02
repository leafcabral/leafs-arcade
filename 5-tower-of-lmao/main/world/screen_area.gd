@tool
class_name ScreenArea
extends Area2D


signal player_entered(area: ScreenArea)
signal player_left(area: ScreenArea)

const COLLISION_SHAPE_CHILD_NAME := "ScreenShape"

@export var shape: RectangleShape2D:
	set = _update_shape


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func get_rect() -> Rect2i:
	var collision_shape := get_node_or_null(COLLISION_SHAPE_CHILD_NAME) as CollisionShape2D
	
	assert(collision_shape, "This ScreenArea shape is not set.")
	
	var rect := collision_shape.shape.get_rect()
	rect.size *= global_scale
	rect.position = global_position - rect.size/2
	
	return Rect2i(rect)


func _update_shape(new_shape: RectangleShape2D) -> void:
	shape = new_shape
	
	var collision_shape := get_node_or_null(COLLISION_SHAPE_CHILD_NAME) as CollisionShape2D

	if collision_shape:
		collision_shape.shape = shape
	else:
		collision_shape = CollisionShape2D.new()
		collision_shape.shape = shape
		collision_shape.name = COLLISION_SHAPE_CHILD_NAME
		add_child(collision_shape)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered.emit(self)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_left.emit(self)
