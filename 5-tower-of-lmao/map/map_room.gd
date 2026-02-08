@tool
class_name MapRoom
extends TileMapLayer


signal player_entered(room: MapRoom)
signal player_exited(room: MapRoom)

const AREA_NAME := "BoundingBox"
const COLLISION_SHAPE_NAME := "RoomShape"

@export_tool_button("Reload " + AREA_NAME, "Reload") var force_reload_area = reload_area

var bounding_box: Area2D
var room_shape: CollisionShape2D

var _rect: Rect2i


func _ready() -> void:
	_create_bounding_box()
	_create_collision_shape()
	reload_area()
	
	bounding_box.body_entered.connect(_on_body_entered)
	bounding_box.body_exited.connect(_on_body_exited)


func get_global_rect() -> Rect2i:
	var global_rect := _rect
	global_rect.size *= Vector2i(global_scale)
	global_rect.position *= Vector2i(global_scale)
	return global_rect


func _create_bounding_box() -> void:
	bounding_box = get_node_or_null(AREA_NAME)
	if not bounding_box:
		bounding_box = Area2D.new()
		bounding_box.name = AREA_NAME
		bounding_box.collision_layer = 0
		bounding_box.collision_mask = 1
		
		add_child(bounding_box)
		bounding_box.owner = get_tree().edited_scene_root


func _create_collision_shape() -> void:
	room_shape = bounding_box.get_node_or_null(COLLISION_SHAPE_NAME)
	if not room_shape:
		room_shape = CollisionShape2D.new()
		room_shape.name = COLLISION_SHAPE_NAME
		room_shape.shape = RectangleShape2D.new()
		room_shape.debug_color = Color.TRANSPARENT
		
		bounding_box.add_child(room_shape)
		room_shape.owner = get_tree().edited_scene_root


func _update_rect() -> void:
	_rect = get_used_rect()
	if tile_set:
		_rect.position *= tile_set.tile_size
		_rect.size *= tile_set.tile_size


func reload_area() -> void:
	_update_rect()
	room_shape.shape.size = _rect.size
	room_shape.position = _rect.get_center()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered.emit(self)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_exited.emit(self)
