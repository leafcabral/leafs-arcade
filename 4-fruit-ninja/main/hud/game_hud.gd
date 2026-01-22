class_name GameHUD
extends CanvasLayer


signal explosion_finished

const MISSED_TRUE := preload("uid://4bjtxjfandrj")
const MISSED_FALSE := preload("uid://by4chl8jgl7l6")


@onready var misses: Array[Node] = $Misses.get_children()
@onready var misses_length := len(misses)
@onready var score_label: RichTextLabel = $Score/ScoreLabel
@onready var high_score_label: RichTextLabel = $Score/HighScoreLabel
@onready var message: RichTextLabel = $Message
@onready var overlay: ColorRect = $Overlay
@onready var overlay_tween: Tween
@onready var continue_button: FruitButton = $Continue
@onready var exit_button: FruitButton = $Exit
@onready var buttons: Array[FruitButton] = [continue_button, exit_button]


func _ready() -> void:
	overlay.modulate = Color.TRANSPARENT
	message.modulate = Color.TRANSPARENT
	continue_button.modulate = Color.TRANSPARENT
	exit_button.modulate = Color.TRANSPARENT
	
	for i in buttons:
		i.disabled = true


func reset_misses() -> void:
	for miss in misses:
		miss.texture = MISSED_FALSE


func set_misses(num_of_misses: int) -> void:
	for i in min(num_of_misses, misses_length):
		misses[i].texture = MISSED_TRUE
	for i in range(num_of_misses + 1, misses_length):
		misses[i].texture = MISSED_FALSE


func update_score(score: int) -> void:
	score_label.text = str(score)


func update_high_score(high_score: int) -> void:
	const string_start := "[font_size=16][color=\"lightgreen\"]high score:\n"
	high_score_label.text = string_start + str(high_score)


func show_game_over_message() -> void:
	show_message("[wave][color=crimson]Game over[/color][/wave]")


func show_paused_message() -> void:
	show_message("[wave][color=gray]Paused[/color][/wave]")


func show_message(text: String, fade_in := 0.3) -> void:
	message.text = text
	
	message.show()
	if fade_in > 0:
		message.modulate = Color(1,1,1,0)
		message.create_tween().tween_property(message, "modulate", Color.WHITE, fade_in)


func hide_message(fade_out := 0.3) -> void:
	message.create_tween().tween_property(message, "modulate", Color(1,1,1,0), fade_out)


func show_explosion_animation() -> void:
	show_overlay_animation(Color.WHITE, Fruit.BOMB_EXPLODE_TIME)
	hide_overlay_animation(Color.TRANSPARENT)
	overlay_tween.tween_callback(explosion_finished.emit)


func show_normal_overlay_animation() -> void:
	show_overlay_animation(Color(0.25, 0.25, 0.25, 0.25))


func show_overlay_animation(final_color: Color, fade_in := 0.3) -> void:
	if overlay_tween:
		if not overlay_tween.is_running():
			overlay_tween.kill()
			overlay_tween = overlay.create_tween()
	else:
		overlay_tween = overlay.create_tween()
	overlay.modulate = Color.TRANSPARENT
	overlay_tween.tween_property(overlay, "modulate", final_color, fade_in)


func hide_overlay_animation(final_color: Color, fade_out := 0.3) -> void:
	if overlay_tween:
		if not overlay_tween.is_running():
			overlay_tween.kill()
			overlay_tween = overlay.create_tween()
	else:
		overlay_tween = overlay.create_tween()
	overlay_tween.tween_property(overlay, "modulate", final_color, fade_out)


func enable_buttons(fade_in := 0.3) -> void:
	for i in buttons:
		i.disabled = false
		i.create_tween().tween_property(i, "modulate", Color.WHITE, fade_in)


func disable_buttons(fade_out := 0.3) -> void:
	for i in buttons:
		i.disabled = true
		i.create_tween().tween_property(i, "modulate", Color.TRANSPARENT, fade_out)


func show_game_over() -> void:
	enable_buttons()
	
	show_game_over_message()
	show_normal_overlay_animation()


func show_paused() -> void:
	enable_buttons()
	
	show_paused_message()
	show_normal_overlay_animation()


func hide_messages() -> void:
	disable_buttons()
	hide_message()
	hide_overlay_animation(Color.TRANSPARENT)


func _on_exit_bomb_sliced() -> void:
	show_explosion_animation()
