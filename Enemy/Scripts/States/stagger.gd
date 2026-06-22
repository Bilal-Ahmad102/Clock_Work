# stagger.gd
extends LimboState
var _timer: float = 0.0

func _enter() -> void:
	agent.sprite.play("hurt")
	agent.velocity.x = 0.0
	_timer = agent.stagger_duration
func _update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		get_root().dispatch(&"recover")
