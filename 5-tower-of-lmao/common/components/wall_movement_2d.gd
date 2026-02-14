@tool
@icon("res://common/components/wall_movement_2d.png")
class_name WallMovement2D
extends Movement2D


signal started_climbing
signal stopped_climbing

const RAY_NAME := ^"WallDetectingRay"
const DEFAULT_DIRECTION := Vector2.RIGHT

@export var input_climb := &"climb"
@export var input_jump := &"jump"

@export_group("Wall Jump", "wall_jump_")
@export_range(0, 1000, 0.1, "or_greater") var wall_jump_horizontal_force := 300.0
@export_range(0, 100, 0.1, "or_greater") var wall_jump_stamina_consumption := 60.0

@export_range(0, 100, 0.1, "or_greater") var stamina_max := 100.0:
	set(value):
		stamina_max = value
		stamina = stamina_max
@export_range(0, 128, 0.1) var length := 64.0:
	set(value):
		length = value
		update_ray_properties()
@export var flip_h := false:
	set(value):
		flip_h = value
		update_ray_properties()
@export_range(0, 1000, 0.1, "or_greater") var max_speed := 250.0
@export_range(0, 100, 0.1, "or_greater") var idle_stamina_consumption := 20.0
@export_range(0, 100, 0.1, "or_greater") var climb_stamina_consumption := 40.0
@export var movement_controller: PlatformerMovement2D

var ray: RayCast2D
var is_active := false
var stamina := stamina_max


func _ready() -> void:
	ray = get_node_or_null(RAY_NAME)
	if not ray:
		ray = RayCast2D.new()
		ray.name = String(RAY_NAME)
		add_child(ray)
	ray.target_position = DEFAULT_DIRECTION * length
	ray.collision_mask = parent.collision_mask
	
	update_ray_properties()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if parent.is_on_floor():
		stamina = stamina_max
	
	if should_climb():
		if not is_active:
			is_active = true
			started_climbing.emit()
	else:
		if is_active:
			is_active = false
			stopped_climbing.emit()


func _update_physics(delta: float) -> void:
	if not is_active:
		velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed(input_jump):
		movement_controller.jump()
		if Input.is_action_pressed(input_right if flip_h else input_left):
			movement_controller.velocity.x = (
				wall_jump_horizontal_force if flip_h
				else - wall_jump_horizontal_force 
			)
		stamina -= wall_jump_stamina_consumption
		velocity = movement_controller.velocity
		return
	
	if Input.is_action_pressed(input_up) and can_move_up(delta):
		velocity.y = - max_speed
		reduce_stamina(climb_stamina_consumption * delta)
	elif Input.is_action_pressed(input_down) and can_move_down(delta):
		velocity.y = max_speed
		reduce_stamina(climb_stamina_consumption * delta)
	else:
		velocity.y = 0
		reduce_stamina(idle_stamina_consumption * delta)


func update_ray_properties() -> void:
	if not ray:
		return
	
	ray.target_position = ray.target_position.normalized() * length
	ray.target_position.x = absf(ray.target_position.x)
	if flip_h:
		ray.target_position.x *= -1


func should_climb() -> bool:
	return (
		ray.is_colliding() and stamina and (
			(Input.is_action_pressed(input_climb) and not movement_controller.is_jumping)
			or Input.is_action_just_pressed(input_climb)
		)
	)


func can_move_up(delta: float) -> bool:
	return _test_if_offset_colliding(-max_speed * delta)


func can_move_down(delta: float) -> bool:
	return _test_if_offset_colliding(max_speed * delta)


func reduce_stamina(amount: float) -> void:
	stamina = maxf(0.0, stamina - amount)


func _test_if_offset_colliding(y_offset: float) -> bool:
	var result: bool
	
	position.y += y_offset
	ray.force_raycast_update()
	result = ray.is_colliding()
	position.y -= y_offset
	ray.force_raycast_update()
	
	return result
