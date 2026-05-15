extends LimboState

var _player: CharacterBody2D
func _setup() -> void:
	_player = agent  # agent = the CharacterBody2D passed to hsm.initialize()

func _enter() -> void:
	_player.sprite.offset.y -= 7
	_player.play_anim(&"sprint_attack")
	_player.velocity.y = PlayerData.JUMP_VELOCITY +  150

func _exit() -> void:
	_player.sprite.offset.y += 7
	
	get_root().previous_state = self
	
func _on_animation_finished() -> void:
	get_root().dispatch("run")
	get_root().previous_state = self

func _update(delta: float) -> void:
	_player.apply_gravity(delta)
