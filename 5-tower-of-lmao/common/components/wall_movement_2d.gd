@tool
@icon("res://common/components/wall_movement_2d.png")
class_name WallMovement2D
extends Movement2D


signal started_climbing
signal stopped_climbing

const CLIMB_RAY_NAME := ^"ClimbingRay"
const WALL_JUMP_RAY_NAME := ^"WallJumpgRay"
const DEFAULT_DIRECTION := Vector2.RIGHT

@export var input_climb := &"climb"
@export var input_jump := &"jump"

@export_range(0, 100, 0.1, "or_greater") var stamina_max := 100.0:
	set(value):
		stamina_max = value
		stamina = stamina_max
@export var movement_controller: PlatformerMovement2D

@export_group("Rays Configuration", "rays_")
@export_range(0, 128, 0.1) var rays_length := 64.0:
	set(value):
		rays_length = value
		update_ray_properties()
@export var rays_flip_h := false:
	set(value):
		rays_flip_h = value
		update_ray_properties()
@export var rays_offset := 0.0:
	set(value):
		rays_offset = value
		update_ray_properties()

@export_group("Climbing")
@export_range(0, 1000, 0.1, "or_greater") var max_speed := 250.0
@export_range(0, 100, 0.1, "or_greater") var idle_stamina_consumption := 20.0
@export_range(0, 100, 0.1, "or_greater") var climb_stamina_consumption := 40.0

@export_group("Wall Jump", "wall_jump_")
@export_range(0, 1000, 0.1, "or_greater") var wall_jump_horizontal_force := 64.0
@export_range(0, 100, 0.1, "or_greater") var wall_jump_stamina_consumption := 60.0

var ray_climb: RayCast2D
var ray_wall_jump: RayCast2D
var is_climbing := false
var is_active := false
var stamina := stamina_max


func _ready() -> void:
	setup_rays()
	update_ray_properties()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if source.is_on_floor():
		stamina = stamina_max
	
	if should_climb():
		if not is_climbing:
			is_climbing = true
			started_climbing.emit()
	else:
		if is_climbing:
			is_climbing = false
			stopped_climbing.emit()


func _update_physics(delta: float) -> void:
	if not (is_climbing and should_wall_jump()):
		velocity = Vector2.ZERO
	
	if should_wall_jump():
		if is_climbing:
			movement_controller.jump()
			if Input.is_action_pressed(input_right if rays_flip_h else input_left):
				movement_controller.velocity.x = (
					wall_jump_horizontal_force if rays_flip_h
					else - wall_jump_horizontal_force 
				)
			stamina -= wall_jump_stamina_consumption
		else:
			movement_controller.wall_jump(
					wall_jump_horizontal_force if rays_flip_h
					else -wall_jump_horizontal_force
			)
		velocity = movement_controller.velocity
	elif is_climbing:
		if Input.is_action_pressed(input_up) and can_move_up(delta):
			velocity.y = - max_speed
			reduce_stamina(climb_stamina_consumption * delta)
		elif Input.is_action_pressed(input_down) and can_move_down(delta):
			velocity.y = max_speed
			reduce_stamina(climb_stamina_consumption * delta)
		else:
			velocity.y = 0
			reduce_stamina(idle_stamina_consumption * delta)


func setup_rays() -> void:
	ray_climb = get_node_or_null(CLIMB_RAY_NAME)
	if not ray_climb:
		ray_climb = RayCast2D.new()
		ray_climb.name = String(CLIMB_RAY_NAME)
		add_child(ray_climb)
	ray_climb.target_position = DEFAULT_DIRECTION * rays_length
	ray_climb.collision_mask = source.collision_mask
	
	ray_wall_jump = get_node_or_null(WALL_JUMP_RAY_NAME)
	if not ray_wall_jump:
		ray_wall_jump = RayCast2D.new()
		ray_wall_jump.name = String(WALL_JUMP_RAY_NAME)
		add_child(ray_wall_jump)
	ray_wall_jump.target_position = DEFAULT_DIRECTION * rays_length
	ray_wall_jump.collision_mask = source.collision_mask


func update_ray_properties() -> void:
	if not (ray_climb and ray_wall_jump):
		return
	
	ray_climb.position.y = - rays_offset / 2
	ray_climb.target_position = ray_climb.target_position.normalized() * rays_length
	ray_climb.target_position.x = absf(ray_climb.target_position.x)
	if rays_flip_h:
		ray_climb.target_position.x *= -1
		
	ray_wall_jump.position.y = rays_offset / 2
	ray_wall_jump.target_position = ray_wall_jump.target_position.normalized() * rays_length
	ray_wall_jump.target_position.x = absf(ray_wall_jump.target_position.x)
	if rays_flip_h:
		ray_wall_jump.target_position.x *= -1


func should_wall_jump() -> bool:
	return (
		ray_wall_jump.is_colliding()
		and stamina
		and movement_controller.is_airbourne
		and movement_controller.jump_pressed
	)


func should_climb() -> bool:
	return (
		ray_climb.is_colliding() and stamina and (
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
	ray_climb.force_raycast_update()
	result = ray_climb.is_colliding()
	position.y -= y_offset
	ray_climb.force_raycast_update()
	
	return result
