extends LimboState
## 2.5 m invincibility dash. 8 inv frames at dash start.
## Costs 20 stamina. Cancellable from light combo (handled in combat states).

var _player   : CharacterBody2D
var _timer    : float = 0.0
var _dir      : float = 1.0
func _setup() -> void:
	_player = agent

func _enter() -> void:
	_player.set_collision_mask_value(2, false)  # 2 = enemy layer
	# Dash manages its own airborne motion — stop player.gd's global
	# auto-fall check from yanking us into `fall` while dashing.
	_player.is_falling = true

	# Determine dash direction from input, fall back to sprite facing
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0.0:
		_dir = sign(input_dir)
	else:
		_dir = -1.0 if _player.sprite.flip_h else 1.0

	PlayerData.dash_direction = _dir
	
	_timer = PlayerData.DASH_DURATION

	# Spend stamina
	PlayerData.spend_stamina(PlayerData.DASH_STAMINA_COST)

	# Grant invincibility frames
	PlayerData.invincibility_timer = float(PlayerData.INV_FRAMES) / 60.0
	PlayerData.is_invincible       = true

	if not _player.sprite.animation_finished.is_connected(_on_animation_finished):
		_player.sprite.animation_finished.connect(_on_animation_finished)

	if get_root().previous_state == get_root().idle:
		_player.play_anim(&"to_dash_idle")
	elif get_root().previous_state in [get_root().run,
			get_root().fall,get_root().idle_jump]:
		print("DASH") 
		_player.play_anim(&"dash")


	PlayerData.dash_started.emit()
func _on_animation_finished() -> void:
	if _player.sprite.animation in ["to_dash_idle"]:
			_player.play_anim(&"dash")
	elif _player.sprite.animation in ["end_dash_idle"]:
			get_root().dispatch(&"idle")


func _exit() -> void:
	_player.set_collision_mask_value(2, true)
	_player.is_falling = false

	get_root().previous_state = self

func _update(delta: float) -> void:
	_timer -= delta

	# Lock velocity during dash — ignore gravity horizontally, keep flat
	_player.velocity.x = _dir * PlayerData.DASH_SPEED
	_player.velocity.y = 0.0

	if _timer <= 0.0:
		_end_dash()

func _end_dash() -> void:
	_player.velocity.x = 0.0
	PlayerData.dash_ended.emit()
	
	if get_root().previous_state == get_root().idle:
		_player.play_anim(&"end_dash_idle")
	elif get_root().previous_state == get_root().run:
		get_root().dispatch(&"run")
	elif get_root().previous_state == get_root().jump:
		get_root().dispatch(&"fall")
	elif get_root().previous_state in [get_root().fall,get_root().idle_jump]:
		get_root().dispatch(&"fall")
