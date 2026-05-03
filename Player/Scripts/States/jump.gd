extends LimboState

var _player: CharacterBody2D

func _setup() -> void:
	_player = agent

func _enter() -> void:
	# Apply jump impulse immediately on enter
	_player.velocity.y = PlayerData.JUMP_VELOCITY
	PlayerData.coyote_timer    = 0.0
	PlayerData.jump_buffer_timer = 0.0
	_player.play_anim(&"jump")
func _exit() -> void:
	get_root().previous_state = self

func _update(delta: float) -> void:
	_player.apply_gravity(delta)
	_player.apply_horizontal(delta, PlayerData.RUN_SPEED)  # full air speed

	# Allow dash in the air
	if Input.is_action_just_pressed("dash") \
			and PlayerData.stamina >= PlayerData.DASH_STAMINA_COST:
		get_root().dispatch(&"dash")
		return

	# ── Transitions ──────────────────────────────────────────
	# Peak of arc → switch to fall for different animation / gravity
	if _player.velocity.y >= 0.0:
		get_root().dispatch(&"fall")
