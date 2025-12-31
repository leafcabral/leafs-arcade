extends Node2D


signal effects_finished


var effect_running: int = 2


func _ready() -> void:
	for child in get_children():
		child.emitting = true
		child.one_shot = true


func _process(_delta: float) -> void:
	if not effect_running:
		effects_finished.emit()


func _on_flying_particles_finished() -> void:
	effect_running -= 1


func _on_static_particles_finished() -> void:
	effect_running -= 1
