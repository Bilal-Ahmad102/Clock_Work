# recover.gd
extends LimboState

var _enemy: CharacterBody2D
var _timer: float = 0.0

func _setup() -> void:
	_enemy = agent

func _enter() -> void:
	_enemy.sprite.play("idle")
	_enemy.velocity.x = 0.0
	_timer = _enemy.recover_duration

func _exit() -> void:
	get_root().previous_state = self

func _update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		if _enemy.is_player_detected():
			get_root().dispatch(&"chase")
		else:
			get_root().dispatch(&"idle")

func _on_animation_finished() -> void:
	pass
