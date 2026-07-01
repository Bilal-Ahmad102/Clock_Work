extends LimboState

var _player: CharacterBody2D
var _transitioning: bool = false  # true while end_walk is still playing

func _setup() -> void:
	_player = agent  # agent = the CharacterBody2D passed to hsm.initialize()

func _enter() -> void:
	
	if get_root().previous_state in  get_root().movement_states:
		if get_root().previous_state == get_root().walk:
			_player.play_anim("idle")
			pass
		elif get_root().previous_state == get_root().run:
			_player.play_anim("end_run")
		_transitioning = true

	else:
		_player.play_anim("idle")
func _exit() -> void:
	get_root().previous_state = self

func _on_animation_finished() -> void:
	if _transitioning and _player.sprite.animation in ["end_run"]:
		_transitioning = false
		_player.play_anim("idle")
		get_root().previous_state = self

func _update(delta: float) -> void:
	# Bleed velocity to zero while idle
	_player.velocity.x = move_toward(_player.velocity.x, 0.0,
		PlayerData.DECELERATION * delta)

	# ── Transitions ──────────────────────────────────────────
	call_transition_inputs()
	
func call_transition_inputs():
	get_root().input_for_run()
	get_root().input_for_dash()
	get_root().input_for_parry()
	get_root().input_for_shield_block()
	get_root().input_for_combo_light_atk()
	get_root().input_for_heavy_atk()
	get_root().input_for_magic_dash_atk()
	get_root().input_for_heavy_dash_atk()
	get_root().input_for_jump()
