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

		## Listen for when to_walk finishes
		if not _player.sprite.animation_finished.is_connected(_on_animation_finished):
			_player.sprite.animation_finished.connect(_on_animation_finished)
	else:
		_player.play_anim("run")

func _exit() -> void:
	# Clean up the signal connection when leaving this state
	if _player.sprite.animation_finished.is_connected(_on_animation_finished):
		_player.sprite.animation_finished.disconnect(_on_animation_finished)
	request_for_idle = false
	get_root().previous_state = self
	
func _on_animation_finished() -> void:
	if _transitioning and _player.sprite.animation == "to_run":
		_transitioning = false
		_player.play_anim("run")

func _update(delta: float) -> void:
	_player.apply_horizontal(delta, PlayerData.RUN_SPEED)
	if request_for_idle:
		get_root().dispatch(&"idle")
		return

	# ── Transitions ──────────────────────────────────────────
	#if not _player.is_on_floor():
		#get_root().dispatch(&"fall")
		#return

	if Input.is_action_just_pressed("dash") \
			and PlayerData.stamina >= PlayerData.DASH_STAMINA_COST:
		get_root().dispatch(&"dash")
		return

	if _jump_requested():
		get_root().dispatch(&"jump")
		return

	var dir := Input.get_axis("move_left", "move_right")
	if dir == 0.0:
		request_for_idle = true
		return

	if not Input.is_action_pressed("run"):
		get_root().dispatch(&"walk")

func _jump_requested() -> bool:
	return PlayerData.jump_buffer_timer > 0.0 \
		or Input.is_action_just_pressed("jump")
