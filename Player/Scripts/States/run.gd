extends LimboState

var _player: CharacterBody2D
var _transitioning: bool = false  # true while end_walk is still playing
var request_for_idle: bool = false

func _setup() -> void:
	_player = agent

func _enter() -> void:
	if get_root().previous_state == get_root().idle:
		_player.play_anim("to_run")
		_transitioning = true

	else:
		_player.play_anim("run")

func _exit() -> void:
	request_for_idle = false
	get_root().previous_state = self
	
func _on_animation_finished() -> void:
	if _transitioning and _player.sprite.animation == "to_run":
		_transitioning = false
		_player.play_anim("run")

func _update(delta: float) -> void:
	_player.apply_horizontal(delta, PlayerData.RUN_SPEED)
	call_transition_inputs()

func call_transition_inputs():
	get_root().input_for_idle()
	get_root().input_for_jump()
	get_root().input_for_sprint_atk()
	get_root().input_for_walk()
	get_root().input_for_dash()
	get_root().input_for_parry()
	get_root().input_for_shield_block()
	get_root().input_for_combo_light_atk()
	get_root().input_for_heavy_atk()
	
	
func _jump_requested() -> bool:
	return PlayerData.jump_buffer_timer > 0.0 \
		or Input.is_action_just_pressed("jump")
