class_name FruitButton
extends Button


signal fruit_sliced(slices: Array[Fruit])
signal bomb_sliced
signal pressed_and_animated

enum Type {
	CONFIRM,
	BACK
}

@export var label_text: String:
	set = change_label_text
@export var type := Type.CONFIRM
@export var should_spin := true

var fruit: Fruit
var _original_velocity: Vector2

@onready var label: Label = $Label
@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	label.text = label_text
	var color = Color.GREEN if type == Type.CONFIRM else Color.RED
	label.add_theme_color_override("font_color", color)
	texture_rect.texture = texture_rect.texture.duplicate()
	texture_rect.texture.gradient = texture_rect.texture.gradient.duplicate()
	texture_rect.texture.gradient.colors[0] = color
	create_fruit()


func create_fruit() -> void:
	if not fruit:
		if type == Type.CONFIRM:
			fruit = Fruit.create_random_normal()
		else:
			fruit = Fruit.create_bomb()
		if should_spin:
			fruit.apply_random_spin()
		fruit.gravity_scale = 0
		
		fruit.connect("sliced", _on_fruit_sliced)
		add_child(fruit)
		
		fruit.position += fruit.sprite.get_size() / 2
		_original_velocity = fruit.linear_velocity
		fruit.linear_velocity = Vector2.ZERO
		
		size = fruit.sprite.get_size()


func handle_interaction() -> void:
	if fruit.type == Fruit.Type.NORMAL:
		fruit.linear_velocity.x = _original_velocity.x
		fruit.gravity_scale = 1
		var slices := fruit.create_slices()
		for i in slices:
			i.position = fruit.global_position
		fruit_sliced.emit(slices)
		
		fruit.queue_free()
	elif fruit.type == Fruit.Type.BOMB:
		bomb_sliced.emit()
		fruit.connect("exploded", func(bomb: Fruit):
			bomb.queue_free()
		)
		fruit.explode()
	pressed_and_animated.emit()
	
	await get_tree().create_timer(1).timeout
	create_fruit()


func change_label_text(new_label: String) -> void:
	label_text = new_label
	if label:
		label.text = label_text


func _on_fruit_sliced(_fruit: Fruit) -> void:
	handle_interaction()


func _on_pressed() -> void:
	handle_interaction()


func _on_visibility_changed() -> void:
	if fruit:
		fruit.toggle_collision(visible)
