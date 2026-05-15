extends LimboState
var _player: CharacterBody2D
var combo_count: int = 0
var can_check_for_walk: bool = false

func _setup() -> void:
	_player = agent

func _enter() -> void:
	if agent.facing_left: _player.sprite.offset = Vector2(-20, -31)
	else:                 _player.sprite.offset = Vector2(20, -31)
	_player.play_anim(&"combo_atk")
	_player.full_stop_movement(true)
	combo_count = 0
	can_check_for_walk = false

func _exit() -> void:
	_player.full_stop_movement(false)
	combo_count = 0
	can_check_for_walk = false
	_player.sprite.offset = Vector2(-2, -21)
	get_root().previous_state = self

func _on_animation_finished() -> void:
	get_root().dispatch(&"idle")

func _update(delta: float) -> void:
	var frame = _player.sprite.frame
	if Input.is_action_just_pressed("combo_atk") and combo_count < 3:
		if frame <= 9 or (frame > 9 and frame <= 15):
			combo_count += 1
			return

	if (frame == 9 and combo_count == 0) or (frame == 15 and combo_count == 1) or frame == 29:
		can_check_for_walk = true
		get_root().dispatch(&"idle")
	else:
		can_check_for_walk = false
