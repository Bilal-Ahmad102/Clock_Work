## Walk.gd
extends LimboState

var _player: CharacterBody2D
var request_for_idle: bool = false
var atk_blocked : bool = false
var sprite : AnimatedSprite2D 
func _setup() -> void:
	_player = agent

func _enter() -> void:
	sprite = _player.sprite
	if get_root().previous_state == get_root().idle:
		play(&"shield_block_initialize")
	else:
		play(&"shield_blocking")
	_player.full_stop_movement(true)

func play(anim_name: StringName):
	sprite.play(anim_name)

func _exit() -> void:
	_player.full_stop_movement(false)
	request_for_idle = false
	get_root().previous_state = self

func _on_animation_finished() -> void:
	print(sprite.animation)
	match sprite.animation:
		&"shield_block_initialize":
			play(&"shield_blocking")
		&"shield_blocking":
			pass
		&"shield_atk_block":
			play(&"shield_blocking")
		&"shield_block_end":
			get_root().dispatch("idle")
			get_root().previous_state = self

@warning_ignore("unused_parameter")
func _update(delta: float) -> void:
	if !get_root().input_for_shield_block() and !request_for_idle:
		request_for_idle = true
		play(&"shield_block_end")
	call_transition_inputs()

func call_transition_inputs():
	get_root().input_for_parry()

func block_attack():
	if sprite.animation == &"shield_blocking":
		play(&"shield_atk_block")
		return true
	else:
		return false
		
