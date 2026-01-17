class_name HealthComponent
extends Node
## Component that gives its parent health that can be damaged.
## 
## [b]HealthComponent[/b] holds an amount of health limited to
## [member MAX_HEALTH].
## [br][br]
## [b]Note:[/b]
## It needs to be manually damaged by other nodes and the damage taken should be
## handled by its parent with this component's signals.


## Emitted when the shield's points reduces by a certain [param amount].
signal shield_damaged(amount: float)
## Emitted when health reduces by a certain [param amount], or increases if 
## [member healing_treated_as_damage] is enabled.
signal damaged(amount: float)
## Emitted when the shield's points increases by a certain [param amount].
signal shield_restored(amount: float)
## Emitted when health increases by a certain [param amount], unless
## [member healing_treated_as_damage] is enabled.
signal healed(amount: float)
## Emitted when the shield's points reaches 0.
signal shield_broken
## Emitted when health reaches 0.
signal died
## Emitted when [member invincibility_time] starts counting down after taking
## damage or when manually called by [method make_invincible] with
## [param silent] set to [code]true[/code]
signal invincibility_started
## Emitted when [member invincibility_time] reaches 0.
signal invincibility_ended


## The maximum value of [member health] and the default value of
## [param new_health] for [method reset_health].
@export_range(1, 100, 0.01, "or_greater") var max_health := 10.0
## The time, in seconds, [member health] won't be able to be reduced after
## taking damage. If [member healing_treated_as_damage] is [code]true[/code]
## health will also not be able to be increased.
@export_range(0, 5, 0.01, "or_greater", "suffix:s") var invincibility_time := 0.5
## If set to [code]true[/code], this node will call [method Node.queue_free()]
## to its parent after [signal dead] is emitted.
@export var free_after_death := false

@export_group("Healing", "healing_")
## If set to [code]true[/code], [member health] can be increased without
## resetting.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var healing_enabled := true
## If set to [code]true[/code] (with [member healing_enabled] also true,
## negative damage will be treated as heal and will trigger [signal damaged]
## instead of [signal healed], while also being subjected to
## [member invincibility_time].
@export var healing_treated_as_damage := false

@export_group("Shield", "shield_")
## If set to [code]true[/code], will treat [member shield] as extra health.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var shield_enabled := false
## The maximum value of [member shield] and the default value of
## [param new_shield] for [method restore_shield].
@export_range(1, 100, 0.01, "or_greater") var shield_max := 10.0
## If set to [code]true[/code], extra damage will be discarted and extra heal 
## won't restore shield.
@export var shield_different_layer := true

var health := 0.0
var shield := 0.0

@onready var _parent := get_parent()
@onready var _hit_cooldown := Timer.new()


func _ready() -> void:
	reset_health(true)
	if shield_enabled:
		restore_shield(true)
	
	add_child(_hit_cooldown)
	_hit_cooldown.timeout.connect(func(): invincibility_ended.emit())
	_hit_cooldown.one_shot = true


func take_damage(damage := 1.0) -> void:
	if is_dead() or is_invincible():
		return
	
	if damage < 0 and healing_treated_as_damage:
		heal(-damage)
	elif not is_shield_broken():
		_damage_shield(damage)
	else:
		_take_damage(damage)


func heal(amount := 1.0) -> void:
	if healing_enabled and amount > 0:
		health += amount
		var health_overflow := health - max_health
		if health_overflow > 0:
			_handle_health_overflow(health_overflow)
		healed.emit(amount - health_overflow)


func make_invincible(silent := false, time := invincibility_time) -> void:
	_hit_cooldown.start(time)
	if not silent:
		invincibility_started.emit()


func reset_health(silent := false, new_health := max_health) -> void:
	var old_health := health
	health = new_health
	
	if not silent:
		healed.emit(new_health - old_health)


func restore_shield(silent := false, new_shield := shield_max) -> void:
	if shield_enabled:
		var old_shield := shield
		shield = new_shield
		
		if not silent:
			shield_restored.emit(new_shield - old_shield)


func is_shield_broken() -> bool:
	return shield <= 0


func is_dead() -> bool:
	return health <= 0


func is_invincible() -> bool:
	return not _hit_cooldown.is_stopped()


func get_health_percentage() -> float:
	return health / max_health


func get_shield_percentage() -> float:
	return shield / shield_max


func _damage_shield(damage: float) -> void:
	if shield_enabled and shield > 0:
		shield -= damage
		var damage_taken := damage if shield >= 0 else damage + shield
		shield_damaged.emit(damage_taken)
		
		if is_shield_broken():
			shield = 0
			shield_broken.emit()
			
			if not shield_different_layer:
				_take_damage(damage_taken)


func _take_damage(damage: float) -> void:
	health -= damage
	damaged.emit(damage)
	
	make_invincible()
	
	if is_dead():
		died.emit()
		
		if free_after_death:
			_parent.queue_free()


func _handle_health_overflow(overflow_amount: float) -> void:
	health -= overflow_amount
	
	if not shield_different_layer:
		restore_shield(false, min(shield_max, shield + overflow_amount))
