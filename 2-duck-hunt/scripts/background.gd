extends Control


@onready var default_bg_color: Color = $ColorRect.color
@onready var dog_node := $Dog
@onready var dog_tween: Tween


func _ready() -> void:
	pass#dog_initial_animaiton()


func dog_initial_animaiton():
	const initial_position := Vector2(-82, 470)
	const final_position_x := 360
	
	const jump_height := 150.0
	const jump_offset_x := 50.0
	const jump_peak := Vector2(
		jump_offset_x + final_position_x, -jump_height + initial_position.y
	)
	const after_jump := jump_peak + Vector2(jump_offset_x/2, jump_height)
	
	dog_node.position = initial_position
	
	cleanup_tween()
	dog_tween = create_tween()
	
	dog_tween.tween_callback(func(): dog_node.play("searching"))
	dog_tween.tween_callback(dog_node.show)
	dog_tween.tween_property(dog_node, "position:x", final_position_x, 7)
	
	dog_tween.tween_callback(func(): dog_node.play("found"))
	dog_tween.tween_interval(1)
	
	dog_tween.tween_callback(func(): dog_node.play("jump"))
	dog_tween.tween_property(
		dog_node, "position", jump_peak, 0.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	dog_tween.tween_property(dog_node, "z_index", 3, 0)
	dog_tween.tween_property(
		dog_node, "position", after_jump, 0.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	dog_tween.tween_callback(dog_node.hide)


func spawn_dog_with_bird(pos_x: int, num_of_birds: int = 1):
	dog_node.play("caught-" + str(clamp(num_of_birds, 1, 3)))
	spawn_dog_generic(pos_x)


func spawn_dog_laugh(pos_x: int):
	dog_node.play("laugh")
	spawn_dog_generic(pos_x)


func spawn_dog_generic(pos_x: int):
	const dog_caught_pos_y_start: int = 460
	const dog_caught_pos_y_end: int = 345
	
	dog_node.position.x = pos_x
	dog_node.z_index = 3
	
	cleanup_tween()
	dog_tween = create_tween()
	
	dog_tween.tween_callback(dog_node.show)
	dog_tween.tween_property(dog_node, "position:y", dog_caught_pos_y_end, 0.3)
	dog_tween.tween_interval(1.5)
	dog_tween.tween_property(dog_node, "position:y", dog_caught_pos_y_start, 0.3)
	dog_tween.tween_callback(dog_node.hide)


func cleanup_tween() -> void:
	if dog_tween:
		dog_tween.kill()
		dog_tween = null


func is_dog_spawned() -> bool:
	if dog_tween:
		return dog_tween.is_running()
	else:
		return false


func can_spawn_dog() -> bool:
	return not is_dog_spawned()


func change_bg_color(color: Color):
	$ColorRect.color = color
	await get_tree().create_timer(1).timeout
	$ColorRect.color = default_bg_color
