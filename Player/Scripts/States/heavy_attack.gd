extends LimboState

var _player: CharacterBody2D
func _setup() -> void:
	_player = agent  # agent = the CharacterBody2D passed to hsm.initialize()

func _enter() -> void:
	_player.play_anim(&"heavy_atk")
	_player.full_stop_movement(true)

func _exit() -> void:
	_player.full_stop_movement(false)
	_player.sprite.offset = Vector2(-2,-21)
	
	get_root().previous_state = self
	
func _on_animation_finished() -> void:
	get_root().dispatch("idle")
	get_root().previous_state = self

func play_FX():
	agent.fx_player.play(&"heavy_atk")

func _update(delta: float) -> void:
	pass
