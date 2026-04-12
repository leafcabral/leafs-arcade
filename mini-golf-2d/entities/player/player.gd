class_name Player
extends Node


const DRIVER_CLUB := preload("uid://co7lprfyeuwgs")
const WOOD_CLUB := preload("uid://cllyoka27wb4x")
const WEDGE_CLUB := preload("uid://dqisdeotk3fkt")
const MAX_ZOOM := Vector2.ONE * 1.5
const MIN_ZOOM := Vector2.ONE * 0.25

@export var spawn_point: SpawnPoint:
	set(value):
		spawn_point = value
		if spawn_point:
			spawn_position = spawn_point.get_real_position()

var strokes := 0
var available_clubs := [DRIVER_CLUB, WOOD_CLUB, WEDGE_CLUB]
var spawn_position := Vector2.ZERO:
	set(value):
		spawn_position = value
		if ball:
			ball.position = spawn_position
var respawn_position := Vector2.ZERO

@onready var club: GolfClub = $Club
@onready var ball: GolfBall = $Ball
@onready var camera: Camera2D = $Ball/Camera


func _ready() -> void:
	spawn()


func _input(event: InputEvent) -> void:
	if not event.is_action_type():
		return
	
	for i in 3:
		if event.is_action_pressed("change_club_" + str(i + 1)):
			club.equip(available_clubs[i])
			break
	
	if event.is_action_pressed("reset_last"):
		respawn()
	if event.is_action_pressed("reset_start"):
		spawn()
	
	if event.is_action_pressed("zoom_reset"):
		camera.zoom = Vector2.ONE


func _process(delta: float) -> void:
	var zoom_amount := Input.get_axis("zoom_out", "zoom_in") * delta
	if zoom_amount:
		zoom(zoom_amount)
	else:
		# Mouse scroll only activates is_action_just_pressed
		zoom_amount = delta * 3
		if Input.is_action_just_pressed("zoom_in"):
			zoom(zoom_amount)
		elif Input.is_action_just_pressed("zoom_out"):
			zoom(-zoom_amount)


func spawn() -> void:
	ball.teleport(spawn_position, false)


func respawn() -> void:
	if strokes:
		ball.teleport(respawn_position)


func zoom(amount: float)-> void:
	var new_zoom := camera.zoom + Vector2(amount, amount)
	if amount > 0:
		camera.zoom = MAX_ZOOM.min(new_zoom)
	elif amount < 0:
		camera.zoom = MIN_ZOOM.max(new_zoom)


func get_hud_data() -> Dictionary:
	return club.get_swing_data().merged({"strokes": strokes})


func _on_ball_stopped_moving() -> void:
	ball.modulate = ball.stop_color


func _on_ball_started_moving() -> void:
	ball.modulate = Color.WHITE


func _on_club_swing_ended() -> void:
	strokes += 1
	respawn_position = ball.global_position
