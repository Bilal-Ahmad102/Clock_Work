# idle.gd
extends LimboState

var _enemy: CharacterBody2D

func _setup() -> void:
	_enemy = agent

func _enter() -> void:
	print(_enemy.sprite)
	if !_enemy.sprite: _enemy.sprite = %AnimatedSprite2D  
	_enemy.sprite.play("idle")
	_enemy.velocity.x = 0.0

func _exit() -> void:
	get_root().previous_state = self

func _update(_delta: float) -> void:
	if _enemy.is_player_detected():
		get_root().dispatch(&"chase")

func _on_animation_finished() -> void:
	pass
