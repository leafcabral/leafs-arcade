class_name HealthComponent
extends Node
## Component that gives its parent health that can be damaged until death and
## healed.
## 
## [b]HealthComponent[/b] holds an amount of health limited to
## [member max_health].
## [b]Note:[/b]
## It needs to be manually damaged by other nodes and the damage taken should be
## handled by its parent with this component's signals.


## Emitted when [member health] reduces,.
signal damaged(amount: float)
## Emitted when [member health] increases.
signal healed(amount: float)
## Emitted when [member health] tries to increase when its value is
## [max_health]
signal overhealed(amount: float)
## Emitted when [member health] reaches 0.
signal died
## Emitted when [member max_health] is changed.
signal max_health_changed(new_health: float, old_health: float)
## Emitted when [member invincibility_time] starts counting down after taking
## damage or when manually called by [method make_invincible] with
## [param silent] set to [code]true[/code]
signal invincibility_started
## Emitted when [member invincibility_time] reaches 0.
signal invincibility_ended


## The maximum value of [member health] and the default value of
## [param new_health] for [method reset_health].
@export_range(1, 100, 0.01, "or_greater") var max_health := 10.0:
	set = change_max_health
## The time, in seconds, [member health] won't be able to be reduced after
## taking damage.
@export_range(0, 5, 0.01, "or_greater", "suffix:s") var invincibility_time := 0.5
## If set to [code]true[/code], this node will call [method Node.queue_free()]
## to its parent after [signal dead] is emitted.
@export var free_after_death := false


@export_group("Healing", "healing_")
## If set to [code]true[/code], [member health] can be increased without
## resetting.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var healing_enabled := true
## If set to [code]true[/code], [method damage] and [method heal] can be used
## for both damaging and healing, with negative damage being considered healing
## and negative healing being considered damage. The correct signals will be
## emitted.
@export var healing_from_negative_damage := false


## Current health, should not be set manually.
var health := 0.0
## Amount of health that was overhealed.
var overflow_health := 0.0

@onready var _hit_cooldown := Timer.new()


func _ready() -> void:
	reset_health(true)
	
	add_child(_hit_cooldown)
	_hit_cooldown.timeout.connect(func(): invincibility_ended.emit())
	_hit_cooldown.one_shot = true


## Damages the node's [member health] by [param amount], or call [method heal]
## if [param amount] is negative and [member healing_from_negative_damage] is
## [code]true[/code].
## Will not work if [method is_dead] or [method is_invincible] returns false.
## [br][br]
## After successfuly damaging [member health], it will emit [signal damaged, and
## emit [signal died] if dead or [signal invincibility_started] if not.
func damage(amount := 1.0) -> void:
	if is_dead() or is_invincible():
		return
	
	if amount > 0:
		_damage(amount)
	elif healing_from_negative_damage:
		heal(-amount)


## Heals the node's [member health] by [param amount], or call [method damage]
## if [param amount] is positive and [member healing_from_negative_damage] is
## [code]true[/code].
## Will not work if [method is_dead] returns false.
## [br][br]
## After successfuly healing [member health], it will emit [signal healed], and
## emit [signal overhealed] if after the heal [member health] was greater than
## [member max_health]
func heal(amount := 1.0) -> void:
	if is_dead():
		return
	
	if healing_enabled:
		if amount > 0:
			_heal(amount)
		elif healing_from_negative_damage:
			damage(-amount)


## Change the current [member max_health] to [param new_health]. If
## [param new_health] is lesser than the current [member health], it will be
## damaged with [method damage].
## [br][br]
## Won't work if [param new_health] is negative.
func change_max_health(new_health: float):
	if new_health < 0:
		return
	
	if new_health < health:
		damage(health - new_health)
	
	var old_max_health = max_health
	max_health = new_health
	
	max_health_changed.emit(max_health, old_max_health)


## Make the [member health] immune to damage for [param time] seconds. If
## [param silent] is false, won't emit [signal invincibility_started].
## Will not work if [method is_dead] returns false.
## [br][br]
func make_invincible(silent := false, time := invincibility_time) -> void:
	if is_dead():
		return
	
	_hit_cooldown.start(time)
	
	if not silent:
		invincibility_started.emit()


## Make the [member health] the value of [param new_health], which is defaulted
## to [member max_health]. If [param silent] is false, signals won't be emitted.
func reset_health(silent := false, new_health := max_health) -> void:
	if new_health < 0:
		return
	
	var old_health := health
	health = min(new_health, max_health)
	
	if not silent:
		var difference := absf(new_health - old_health)
		if health > old_health:
			healed.emit(difference)
		else:
			damaged.emit(difference)


## Returns true if [member health] is greater than or equal to 0.
func is_dead() -> bool:
	return health <= 0


## Returns true if [member health] cannot be damaged because it is invulnerable.
func is_invincible() -> bool:
	return not _hit_cooldown.is_stopped()


## Returns the ratio between [member health] and [member max_health], between
## [code]0[/code] and [code]1[/code].
func get_proportion() -> float:
	return health / max_health


## Returns the difference between [member max_health] and [member health].
func get_available() -> float:
	return max_health - health


func _damage(amount: float) -> void:
	health -= amount
	damaged.emit(amount)
	
	if is_dead():
		died.emit()
		
		if free_after_death:
			get_parent().queue_free()
	elif invincibility_time > 0:
		make_invincible()


func _heal(amount: float):
	health += amount
	var overheal := minf(0, health - max_health)
	if overheal > 0:
		overhealed.emit(overheal)
	healed.emit(amount - overheal)
