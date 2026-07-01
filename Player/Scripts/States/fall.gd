## Fall.gd
## Descending phase. Also entered when walking off a ledge (coyote time window).
## Coyote jump is still available for COYOTE_TIME seconds after leaving the floor.
extends LimboState

var _player: CharacterBody2D

func _setup() -> void:
	_player = agent

func _enter() -> void:
	_player.play_anim(&"fall")
	_player.is_falling = true

func _exit() -> void:
	get_root().previous_state = self
	_player.is_falling = false
	
func _update(delta: float) -> void:
	_player.apply_gravity(delta)
	_player.apply_horizontal(delta, PlayerData.RUN_SPEED)
	get_root().check_for_edge_grab()
	# Coyote jump — can still jump briefly after leaving a ledge
	if _jump_requested() and PlayerData.coyote_timer > 0.0:
		get_root().dispatch(&"jump")
		return



	# ── Transitions ──────────────────────────────────────────
	if _player.is_on_floor():
		get_root().dispatch(&"land")
	
	get_root().input_for_dash()

func _jump_requested() -> bool:
	return PlayerData.jump_buffer_timer > 0.0 \
		or Input.is_action_just_pressed("jump")
