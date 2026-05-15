## Walk.gd
extends LimboState

var _player: CharacterBody2D
var _transitioning: bool = false  # true while to_walk is still playing
var request_for_idle: bool = false
func _setup() -> void:
	_player = agent

func _enter() -> void:

	if get_root().previous_state == get_root().idle:
		_player.play_anim_then_loop("shield_block",4,7)
		_transitioning = true
	else:
		_player.play_anim_looped("shield_block",4,7)

func _exit() -> void:
	request_for_idle = false
	get_root().previous_state = self

func _on_animation_finished() -> void:
	get_root().dispatch("idle")
	get_root().previous_state = self

func _update(delta: float) -> void:
	if !get_root().input_for_shield_block() and !request_for_idle:
		request_for_idle = true
		_player.play_anim_rest("shield_block",7)
