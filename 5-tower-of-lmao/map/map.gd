class_name Map
extends Node2D


signal player_exited_screen

@export var player_camera: Camera2D

var rooms_in_touch: Array[MapRoom]
var active_room: MapRoom
var current_checkpoint: Checkpoint


func _ready() -> void:
	var all_rooms := find_children("*", "MapRoom")
	var all_checkpoints := find_children("*", "Checkpoint")
	for i in all_rooms:
		i.player_entered.connect(_on_map_room_player_entered)
		i.player_exited.connect(_on_map_room_player_exited)
	for i in all_checkpoints:
		i.player_entered.connect(_on_checkpoint_player_entered)


func _handle_screen_change() -> void:
	if rooms_in_touch.is_empty():
		return
	
	var last_entered_screen := rooms_in_touch[0]
	
	if active_room != last_entered_screen:
		var screen_rect := last_entered_screen.get_global_rect()
		
		player_camera.limit_top = screen_rect.position.y
		player_camera.limit_left = screen_rect.position.x
		player_camera.limit_bottom = screen_rect.end.y
		player_camera.limit_right = screen_rect.end.x
		
		active_room = last_entered_screen


func _on_map_room_player_entered(area: MapRoom) -> void:
	rooms_in_touch.append(area)
	_handle_screen_change()


func _on_map_room_player_exited(area: MapRoom) -> void:
	rooms_in_touch.erase(area)
	
	if rooms_in_touch.is_empty():
		player_exited_screen.emit()
	
	_handle_screen_change()


func _on_checkpoint_player_entered(checkpoint: Checkpoint) -> void:
	current_checkpoint = checkpoint
