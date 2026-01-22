class_name ExplosionLayer
extends CanvasLayer


signal explosion_peak
signal explosion_ended

@onready var color_rect: ColorRect = $ColorRect
@onready var tween: Tween


func explode(fade_in := 0.6, fade_out := 0.3) -> void:
	if tween:
		tween.kill()
	tween = color_rect.create_tween()
	
	tween.tween_property(color_rect, "modulate", Color.WHITE, fade_in)
	tween.tween_callback(explosion_peak.emit)
	tween.tween_property(color_rect, "modulate", Color.TRANSPARENT, fade_out)
	tween.tween_callback(explosion_ended.emit)
