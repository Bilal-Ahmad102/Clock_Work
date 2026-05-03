## Walk.gd
extends LimboState

var _player: CharacterBody2D
var _transitioning: bool = false  # true while to_walk is still playing
var request_for_idle: bool = false
func _setup() -> void:
	_player = agent

func _enter() -> void:
	if get_root().previous_state == get_root().idle:
		_player.play_anim("to_walk")
		_transitioning = true

		## Listen for when to_walk finishes
		if not _player.sprite.animation_finished.is_connected(_on_animation_finished):
			_player.sprite.animation_finished.connect(_on_animation_finished)
	else:
		_player.play_anim("walk")

func _exit() -> void:
	# Clean up the signal connection when leaving this state
	if _player.sprite.animation_finished.is_connected(_on_animation_finished):
		_player.sprite.animation_finished.disconnect(_on_animation_finished)
	request_for_idle = false
	get_root().previous_state = self
	
func _on_animation_finished() -> void:
	if _transitioning and _player.sprite.animation == "to_walk":
		_transitioning = false
		_player.play_anim("walk")

func _update(delta: float) -> void:
	
	_player.apply_horizontal(delta, PlayerData.WALK_SPEED)
	if request_for_idle:
		# Check if on a last frame
		if _player.sprite.frame in [13,14,15,16,17,0,1,2,3,4]:
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

	if Input.is_action_pressed("run"):
		get_root().dispatch(&"run")

func _jump_requested() -> bool:
	return PlayerData.jump_buffer_timer > 0.0 \
		or Input.is_action_just_pressed("jump")
