extends CharacterBody2D


const MOVEMENT_SPEED := 300.0
const TURN_SPEED := TAU

@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var sprite_size: Vector2 = $MainSprite.get_rect().size * scale
@onready var thruster_sprite: Sprite2D = $ThrusterSprite


func _physics_process(delta: float) -> void:
	var turn_direction := Input.get_axis("turn_left", "turn_right")
	rotation += turn_direction * TURN_SPEED * delta
	
	var acceleration := MOVEMENT_SPEED * delta
	if Input.is_action_pressed("thurster"):
		var direction := Vector2.from_angle(rotation)
		var max_velocity := direction * MOVEMENT_SPEED
		velocity = velocity.move_toward(max_velocity, acceleration)
		
		thruster_sprite.visible = not thruster_sprite.visible
	else:
		velocity = velocity.move_toward(Vector2(), acceleration / 2)
		
		thruster_sprite.visible = false
	
	move_and_slide()
	
	var border_offset := sprite_size / 2
	global_position.x = wrapf(global_position.x, -border_offset.x, viewport_size.x + border_offset.x)
	global_position.y = wrapf(global_position.y, -border_offset.y, viewport_size.y + border_offset.y)
