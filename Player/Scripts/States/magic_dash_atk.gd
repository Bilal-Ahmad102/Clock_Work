extends LimboState
## 2.5 m invincibility dash. 8 inv frames at dash start.
## Costs 20 stamina. Cancellable from light combo (handled in combat states).
@export var DASH_HITBOX_SCENE : PackedScene
var _dash_hitbox: Area2D

var _player   : CharacterBody2D
var _timer    : float = 0.0
var _dir      : float = 1.0
func _setup() -> void:
	_player = agent


func _enter() -> void:
	_player.set_collision_mask_value(2, false)
	# Determine dash direction from input, fall back to sprite facing
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0.0:
		_dir = sign(input_dir)
	else:
		_dir = -1.0 if _player.sprite.flip_h else 1.0
	
	# spawn and add hitbox
	_dash_hitbox = DASH_HITBOX_SCENE.instantiate()
	_player.get_parent().add_child(_dash_hitbox)
	_dash_hitbox._setup_dash_shape()
	_dash_hitbox.change_direction(_player.facing_left)
	_dash_hitbox.global_position = _player.global_position
	_player.set_collision_mask_value(2, false)  # 2 = enemy layer 
	_player.sprite.offset = Vector2(-2,-18)


	PlayerData.dash_direction = _dir
	
	_timer = PlayerData.MAGIC_DASH_DURATION

	# Spend stamina
	PlayerData.spend_mana(PlayerData.MAGIC_DASH_MANA_COST)

	# Grant invincibility frames
	PlayerData.invincibility_timer = float(PlayerData.MAGIC_INV_FRAMES) / 60.0
	PlayerData.is_invincible       = true

	if not _player.sprite.animation_finished.is_connected(_on_animation_finished):
		_player.sprite.animation_finished.connect(_on_animation_finished)

	_player.play_anim(&"magic_dash_atk")



	PlayerData.magic_dash_atk_started.emit()
	_player.sprite.frame_changed.connect(_on_combo_frame_changed)

func _on_animation_finished() -> void:
	get_root().dispatch(&"idle")


func _on_combo_frame_changed() -> void:
	match _player.sprite.frame:
		# hit frames for each combo stage ; adjust to your spritesheet
		19,20,21,22,23,24: _dash_hitbox._activate_hitbox(PlayerData.MAGIC_HEAVY_ATTACK_DAMAGE)
		_:                       _dash_hitbox._deactivate_hitbox()

func _exit() -> void:
	_player.set_collision_mask_value(2, true)  # 2 = enemy layer 
	if _player.sprite.frame_changed.is_connected(_on_combo_frame_changed):
		_player.sprite.frame_changed.disconnect(_on_combo_frame_changed)
	_player.sprite.offset = Vector2(-2,-21)

	get_root().previous_state = self

func _update(delta: float) -> void:
	if _player.sprite.frame <= 18:
		_player.full_stop_movement(true)
		return
	_timer -= delta

	# Lock velocity during dash — ignore gravity horizontally, keep flat
	_player.velocity.x = _dir * PlayerData.MAGIC_DASH_SPEED
	_player.velocity.y = 0.0

	if _timer <= 0.0:
		_end_magic_dash_atk()

func _end_magic_dash_atk() -> void:
	_player.velocity.x = 0.0
	PlayerData.magic_dash_atk_ended.emit()
