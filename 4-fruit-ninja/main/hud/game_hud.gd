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
@onready var explosion: ColorRect = $Explosion


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


func show_game_over_message(fade_in := 0.3) -> void:
	show_message("[wave][color=crimson]Game over[/color][/wave]\n[font_size=16][outline_size=8]Press ENTER or SPACE to play again", fade_in)


func show_message(text: String, fade_in := 0.0) -> void:
	message.text = text
	
	message.show()
	if fade_in > 0:
		message.modulate = Color(1,1,1,0)
		message.create_tween().tween_property(message, "modulate", Color.WHITE, fade_in)


func hide_message(fade_out := 0.0) -> void:
	message.create_tween().tween_property(message, "modulate", Color(1,1,1,0), fade_out)


func show_explosion_animation(fade_in := Fruit.BOMB_EXPLODE_TIME, fade_out := 0.3) -> void:
	explosion.modulate = Color(1,1,1,0)
	var explosion_tween := explosion.create_tween()
	explosion_tween.tween_property(explosion, "modulate", Color.WHITE, fade_in)
	explosion_tween.tween_property(explosion, "modulate", explosion.modulate, fade_out)
	explosion_tween.tween_callback(explosion_finished.emit)
