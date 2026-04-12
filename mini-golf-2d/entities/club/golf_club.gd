@tool
class_name GolfClub
extends Node2D


signal swing_started
signal swing_ended

const DRIVER: GolfClubType = preload("uid://co7lprfyeuwgs")
const WEDGE: GolfClubType  = preload("uid://dqisdeotk3fkt")
const WOOD: GolfClubType  = preload("uid://cllyoka27wb4x")

@export var type: GolfClubType:
	set = equip
@export var ball: GolfBall

var clubs := [DRIVER, WOOD, WEDGE]

@onready var shot_area: DragThrowArea2D = $ShotArea
@onready var club: Sprite2D = $Club
@onready var swing_direction: Sprite2D = $SwingDirection
@onready var CLUB_OFFSET_X := absf(club.offset.x)

var is_swinging := false


func _ready() -> void:
	if not Engine.is_editor_hint():
		club.hide()


func _physics_process(_delta: float) -> void:
	if not is_swinging or Engine.is_editor_hint():
		return
	
	update_visuals()


func _input(event: InputEvent) -> void:
	for i in range(1, 4):
		if event.is_action_pressed("change_club_" + str(i)):
			type = clubs[i - 1]
			break


func update_visuals() -> void:
	swing_direction.visible = shot_area.drag != Vector2.ZERO
	club.visible = swing_direction.visible
	if not swing_direction.visible:
		return
	
	var magnitude := shot_area.get_drag_baked_length()
	
	swing_direction.scale.x = remap(magnitude, 0, 1, 1, 5)
	swing_direction.rotation = shot_area.drag.angle()
	
	club.position.x = remap(magnitude, 0, 1, 0.3, 2) * 50
	club.offset.x = CLUB_OFFSET_X
	club.flip_h = shot_area.should_invert()
	if not club.flip_h:
		club.offset.x *= -1
		club.position.x *= -1


func get_swing_data() -> Dictionary:
	return {
			'power': shot_area.get_drag_percentage() if is_swinging else 0.0,
			'angle': shot_area.get_drag_angle_q1() if is_swinging else 0.0
		}


func equip(new_club: GolfClubType) -> void:
	type = new_club
	if not type:
		return
	
	if not is_node_ready():
		await ready
	
	club.texture = type.texture
	shot_area.minimum_angle = -type.minimum_angle
	shot_area.maximum_angle = type.maximum_angle


func _on_shot_area_grabbed() -> void:
	if not ball.sleeping:
		return
	
	is_swinging = true
	swing_started.emit()


func _on_shot_area_released(cancelled: bool) -> void:
	if not is_swinging:
		return
	
	is_swinging = false
	swing_ended.emit()
	
	swing_direction.visible = false
	var club_tween := club.create_tween()
	club_tween.tween_property(club, "position:x", 0, 0.05)
	if ball and not cancelled:
		club_tween.tween_callback(ball.apply_central_impulse.bind(shot_area.drag * type.power))
	club_tween.tween_property(club, "visible", false, 0.1)
