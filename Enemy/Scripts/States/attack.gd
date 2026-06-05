
extends LimboState

var _enemy:   CharacterBody2D
var _timer:   float = 0.0
var _attacked: bool  = false

func _setup() -> void:
	_enemy = agent

func _enter() -> void:
	_enemy.velocity.x = 0.0
	_timer    = _enemy.attack_cooldown
	_attacked = false
	_enemy.face_player()

	_do_attack()

func _do_attack() -> void:
	_attacked = true
	# randomly pick light or heavy
	if randf() < 0.6:
		_enemy.sprite.play("light_atk")
	else:
		_enemy.sprite.play("heavy_atk")

func _exit() -> void:
	get_root().previous_state = self

func _update(delta: float) -> void:
	_timer -= delta
	_enemy.face_player()

	if _timer <= 0.0:
		get_root().dispatch(&"recover")

func _on_animation_finished() -> void:
	if not _attacked:
		_do_attack()
