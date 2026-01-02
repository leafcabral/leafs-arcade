extends StaticBody2D

const MAX_HEALTH: int = 3
const AVG_SPEED := 100.0

static var min_radius := 32.0
static var num_of_vertices: int = 8

var health := MAX_HEALTH

@onready var vertices := create_vertices()
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D


func _ready() -> void:
	collision_polygon_2d.polygon = vertices
	rotation = PI / num_of_vertices
	
	constant_angular_velocity = randfn(0, PI / 2)
	constant_linear_velocity = Vector2(
		randfn(AVG_SPEED, 50),
		randfn(AVG_SPEED, 50)
	)


func _process(delta: float) -> void:
	rotation = lerp_angle(rotation, rotation + constant_angular_velocity, delta)
	#position += constant_linear_velocity * delta
	
	queue_redraw()


func _draw() -> void:
	var vertices_repeat = vertices.duplicate()
	vertices_repeat.push_back(vertices[0])
	
	draw_polyline(vertices_repeat, Color("white"), 5, true)


func create_vertices() -> PackedVector2Array:
	var vertices_temp := PackedVector2Array()
	
	var radius := min_radius * 2 ** (health - 1)
	for i in num_of_vertices:
		var angle := deg_to_rad(i * 360.0 / num_of_vertices)
		var random_radius := randf_range(radius/4, radius)
		
		var current_vertex := Vector2(
			sin(angle) * random_radius,
			cos(angle) * random_radius
		)
		
		vertices_temp.append(current_vertex)
	
	return vertices_temp
