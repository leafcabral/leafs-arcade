@tool
class_name ScreenMap
extends Area2D


signal player_entered(area: ScreenMap)
signal player_left(area: ScreenMap)

const TILEMAP_NAME := "Layout"
const COLLISION_SHAPE_NAME := "MapShape"

@export_tool_button("Reload " + COLLISION_SHAPE_NAME, "Reload") var reload_map = _on_reload_map_pressed

var tilemap: TileMapLayer
var collision_shape: CollisionShape2D
var shape: RectangleShape2D

var _rect: Rect2i


func _ready() -> void:
	_create_collision_shape()
	_create_tilemap()
	
	_update_rect()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func get_global_rect() -> Rect2i:
	var global_rect := _rect
	global_rect.size *= Vector2i(global_scale)
	global_rect.position *= Vector2i(global_scale)
	return global_rect


func _create_tilemap() -> void:
	tilemap = get_node_or_null(TILEMAP_NAME)
	
	if not tilemap:
		tilemap = TileMapLayer.new()
		tilemap.name = TILEMAP_NAME
		
		add_child(tilemap)
		
		tilemap.owner = get_tree().edited_scene_root


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


func _update_rect() -> void:
	_rect = tilemap.get_used_rect()
	if tilemap.tile_set:
		_rect.position *= tilemap.tile_set.tile_size
		_rect.size *= tilemap.tile_set.tile_size


func _on_reload_map_pressed() -> void:
	_update_rect()
	shape.size = _rect.size
	collision_shape.position = _rect.get_center()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered.emit(self)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_left.emit(self)
