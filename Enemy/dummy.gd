extends CharacterBody2D

## Training dummy. With the default flags it behaves like the original:
## soaks hits and refills whenever health runs out. The intro-level blockout
## configures each teaching beat through the exports below.

signal broke(by_atk: StringName)

@export var max_health := 100.0
## Ignore hits weaker than this (sealed / armored targets never break).
@export var damage_threshold := 0.0
## When health reaches 0: emit `broke` and collapse instead of refilling.
@export var permanent_break := false
## Only the combo finisher (combo_atk_3) may land the breaking blow;
## any other killing hit refills the dummy instead.
@export var require_finisher := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar

const GRAVITY := 980.0

var health: float
var is_hit: bool = false

func _ready() -> void:
	add_to_group("TrainingDummy")
	health = max_health
	health_bar.value = 100.0
	sprite.play("idle")

func take_damage(amount: float, by_atk: StringName = &"") -> void:
	if is_hit:
		return
	if amount < damage_threshold:
		_play_deflect()
		return

	health = max(0.0, health - amount)
	health_bar.value = (health / max_health) * 100.0

	if health <= 0.0:
		if require_finisher and by_atk != &"combo_atk_3":
			_refill()
		elif permanent_break:
			_break(by_atk)
		else:
			_refill()
		return

	_play_hit()

func _play_hit() -> void:
	is_hit = true
	sprite.play("hit")
	await sprite.animation_finished
	sprite.play("idle")
	is_hit = false

func _play_deflect() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.5, 1.5, 1.5), 0.06)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.12)

func _refill() -> void:
	is_hit = true
	sprite.play("hit")
	await sprite.animation_finished
	health = max_health
	health_bar.value = 100.0
	is_hit = false
	sprite.play("idle")

func _break(by_atk: StringName) -> void:
	is_hit = true
	broke.emit(by_atk)
	sprite.play("hit")
	await sprite.animation_finished
	modulate.a = 0.25
	health_bar.visible = false
	set_deferred("collision_layer", 0)
