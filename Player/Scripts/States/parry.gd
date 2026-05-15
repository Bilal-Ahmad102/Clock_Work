extends LimboState

var _player: CharacterBody2D
var combo_atk : int = 0
func _setup() -> void:
	_player = agent  # agent = the CharacterBody2D passed to hsm.initialize()

func _enter() -> void:
	if !agent.facing_left: _player.sprite.flip_h = true
	else: _player.sprite.flip_h = false

	_player.sprite.offset = Vector2(-2,-31)
	_player.play_anim(&"parry")
	_player.full_stop_movement(true)

func _exit() -> void:
	if !agent.facing_left: _player.sprite.flip_h = false
	else: _player.sprite.flip_h = true


	_player.full_stop_movement(false)
	_player.sprite.offset = Vector2(-2,-21)
	get_root().previous_state = self
	
func _on_animation_finished() -> void:
	get_root().dispatch("idle")
