extends StaticBody2D

static var AVG_SPEED := 100.0
static var min_radius := 32.0
static var num_of_vertices: int = 8

var vertices: PackedVector2Array

@onready var parent := get_parent()
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var radius: float:
	get: return min_radius * 2 ** (health_component.health - 1)


func _ready() -> void:
	update_vertices()
	randomize_velocities()
	
	$WrapScreenComponent.border_offset = Vector2(radius, radius)


func _physics_process(delta: float) -> void:
	rotation = lerp_angle(rotation, rotation + constant_angular_velocity, delta)
	move_and_collide(constant_linear_velocity * delta)
	
	queue_redraw()


func _draw() -> void:
	var vertices_repeat = vertices.duplicate()
	vertices_repeat.push_back(vertices[0])
	
	draw_polyline(vertices_repeat, Color("white"), 5, true)


func update_vertices() -> void:
	vertices = create_vertices()
	collision_polygon_2d.polygon = vertices


func create_vertices() -> PackedVector2Array:
	var vertices_temp := PackedVector2Array()
	
	var radius_temp := radius
	for i in num_of_vertices:
		var angle := deg_to_rad(i * 360.0 / num_of_vertices)
		var random_radius := randf_range(radius_temp/4, radius_temp)
		
		var current_vertex := Vector2(
			sin(angle) * random_radius,
			cos(angle) * random_radius
		)
		
		vertices_temp.append(current_vertex)
	
	return vertices_temp


func randomize_velocities() -> void:
	constant_angular_velocity = randfn(0, PI / 2)
	var linear_direction := Vector2.from_angle(randf_range(0, TAU))
	constant_linear_velocity = linear_direction * randfn(AVG_SPEED, 50)


func take_damage(_damage: float) -> void:
	update_vertices()
	var other_asteroid := duplicate()
	parent.add_child(other_asteroid)