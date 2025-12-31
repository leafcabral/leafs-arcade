extends CharacterBody2D


const MOVEMENT_SPEED := 300.0
const TURN_SPEED := TAU

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
