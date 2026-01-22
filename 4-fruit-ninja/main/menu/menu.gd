class_name Menu
extends CanvasLayer


signal continue_pressed
signal exit_pressed

const VFX_DURATION := 0.3

@onready var overlay: ColorRect = $All/Overlay
@onready var message: RichTextLabel = $All/Message
@onready var continue_button: FruitButton = $All/ContinueButton
@onready var exit_button: FruitButton = $All/ExitButton

@onready var all: Control = $All
@onready var buttons: Array[FruitButton] = [continue_button, exit_button]

@onready var all_tween: Tween


func _ready() -> void:
	change_menu_visibility(false)


func change_menu_visibility(become_visible: bool) -> void:
	_create_all_tween()
	
	var color := Color.WHITE if become_visible else Color.TRANSPARENT
	all_tween.tween_property(all, "modulate", color, VFX_DURATION)
	
	for i in buttons:
		i.visible = become_visible


func show_game_over() -> void:
	message.modulate = Color.CRIMSON
	message.text = "[wave]GAME OVER"
	continue_button.label_text = "Try again"
	
	change_menu_visibility(true)


func hide_menu() -> void:
	change_menu_visibility(false)


func _create_all_tween() -> void:
	if all_tween:
		all_tween.kill()
	all_tween = all.create_tween()


func _on_continue_button_pressed_and_animated() -> void:
	continue_pressed.emit()


func _on_exit_button_pressed_and_animated() -> void:
	exit_pressed.emit()


func _on_continue_button_fruit_sliced(slices: Array[Fruit]) -> void:
	for i in slices:
		call_deferred("add_child", i)
