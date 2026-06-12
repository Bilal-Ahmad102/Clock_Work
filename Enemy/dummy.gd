extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar

const MAX_HEALTH := 100.0
const GRAVITY := 980.0

var health: float = MAX_HEALTH
var is_hit: bool = false

func _ready() -> void:
	sprite.play("idle")


func take_damage(amount: float) -> void:
	print(amount)
	if is_hit:
		return

	health = max(0.0, health - amount)
	health_bar.value = (health / MAX_HEALTH) * 100.0

	if health <= 0.0:
		_refill()
		return

	_play_hit()

func _play_hit() -> void:
	is_hit = true
	sprite.play("hit")
	await sprite.animation_finished
	sprite.play("idle")
	is_hit = false

func _refill() -> void:
	is_hit = true
	sprite.play("hit")
	await sprite.animation_finished
	health = MAX_HEALTH
	health_bar.value = 100.0
	is_hit = false
	sprite.play("idle")
