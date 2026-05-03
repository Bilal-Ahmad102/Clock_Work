extends LimboState

var _player: CharacterBody2D
var _transitioning: bool = false  # true while end_walk is still playing

func _setup() -> void:
	_player = agent  # agent = the CharacterBody2D passed to hsm.initialize()

func _enter() -> void:
	
	if get_root().previous_state in  get_root().movement_states:
		if get_root().previous_state == get_root().walk:
			_player.play_anim("end_walk")
		elif get_root().previous_state == get_root().run:
			_player.play_anim("end_run")
		_transitioning = true

		## Listen for when end_walk finishes
		if not _player.sprite.animation_finished.is_connected(_on_animation_finished):
			_player.sprite.animation_finished.connect(_on_animation_finished)
	else:
		_player.play_anim("idle")

func _exit() -> void:
	# Clean up the signal connection when leaving this state
	if _player.sprite.animation_finished.is_connected(_on_animation_finished):
		_player.sprite.animation_finished.disconnect(_on_animation_finished)
	
	get_root().previous_state = self
	
func _on_animation_finished() -> void:
	if _transitioning and _player.sprite.animation in ["end_walk","end_run"]:
		_transitioning = false
		_player.play_anim("idle")
		get_root().previous_state = self

func _update(delta: float) -> void:
	# Bleed velocity to zero while idle
	_player.velocity.x = move_toward(_player.velocity.x, 0.0,
		PlayerData.DECELERATION * delta)

	# ── Transitions ──────────────────────────────────────────
	#if not _player.is_on_floor():
		#get_root().dispatch(&"fall")
		#return

	if Input.is_action_just_pressed("dash") \
			and PlayerData.stamina >= PlayerData.DASH_STAMINA_COST:
		get_root().dispatch(&"dash")
		return
#
	#if _jump_requested():
		#get_root().dispatch(&"jump")
		#return

	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		if Input.is_action_pressed("run"):
			get_root().dispatch(&"run")
		else:
			get_root().dispatch(&"walk")

func _jump_requested() -> bool:
	return PlayerData.jump_buffer_timer > 0.0 \
		or Input.is_action_just_pressed("jump")
