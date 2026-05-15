## Walk.gd
extends LimboState

var _player: CharacterBody2D
func _setup() -> void:
	_player = agent

func _enter() -> void:
	if get_root().previous_state == get_root().idle:
		_player.play_anim_then_loop("full_walk",3,21)

		## Listen for when to_walk finishes
	else:
		_player.play_anim_looped("full_walk",3,21)

func _exit() -> void:
	get_root().previous_state = self
	
func _on_animation_finished() -> void:
	get_root().dispatch(&"idle")

func _update(delta: float) -> void:
	
	_player.apply_horizontal(delta, PlayerData.WALK_SPEED)
