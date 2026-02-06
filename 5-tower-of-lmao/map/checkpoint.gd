@tool
class_name Checkpoint
extends Area2D


signal player_entered(checkpoint: Checkpoint)

const COLLISION_SHAPE_NAME := "CheckpointArea"

var collision_shape: CollisionShape2D
var shape: RectangleShape2D


func _ready() -> void:
	_create_collision_shape()
	
	body_entered.connect(_on_body_entered)


func get_center() -> Vector2:
	return to_global(shape.get_rect().get_center())


func get_base() -> Vector2:
	return to_global(Vector2(get_center().x, shape.get_rect().end.y))


func _create_collision_shape() -> void:
	collision_shape = get_node_or_null(COLLISION_SHAPE_NAME)
	
	if not collision_shape:
		collision_shape = CollisionShape2D.new()
		collision_shape.name = COLLISION_SHAPE_NAME
		shape = RectangleShape2D.new()
		collision_shape.shape = shape
		
		add_child(collision_shape)
		collision_shape.owner = get_tree().edited_scene_root
	else:
		shape = collision_shape.shape


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered.emit(self)
