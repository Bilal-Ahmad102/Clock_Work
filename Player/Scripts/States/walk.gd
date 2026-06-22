## Walk.gd
extends LimboState

var _player: CharacterBody2D
func _setup() -> void:
	_player = agent

func _enter() -> void:
	if get_root().previous_state == get_root().idle:
		play_anim_then_loop("full_walk",3,21)

	else:
		play_anim_looped("full_walk",3,21)
func _exit() -> void:
	get_root().previous_state = self
	disconnect_signals()
	
func _on_animation_finished() -> void:
	get_root().dispatch(&"idle")

func _update(delta: float) -> void:
	
	_player.apply_horizontal(delta, PlayerData.WALK_SPEED)
	call_transition_inputs()


func play_anim_then_loop(anim: StringName, transition_frame: int = 0, end_frame: int = 0) -> void:
	if _player.sprite.animation != anim:
		_player.sprite.play(anim)
		
		if !_player.sprite.frame_changed.is_connected(_on_transition_frame_changed):
			_player.sprite.frame_changed.connect(_on_transition_frame_changed.bind(anim, transition_frame, end_frame))

func _on_transition_frame_changed(anim: StringName, transition_frame: int, end_frame: int) -> void:
	if _player.sprite.frame >= transition_frame:
		_player.sprite.frame_changed.disconnect(_on_transition_frame_changed)
		play_anim_looped(anim, transition_frame, end_frame)

func play_anim_looped(anim: StringName, start_frame: int, end_frame: int) -> void:
	_player.sprite.frame = start_frame
	_player.play_anim(anim, start_frame)
	if !_player.sprite.frame_changed.is_connected(_on_frame_changed):
		_player.sprite.frame_changed.connect(_on_frame_changed.bind(start_frame, end_frame))

func _on_frame_changed(start_frame: int, end_frame: int) -> void:
	if _player.sprite.frame >= end_frame:
		_player.sprite.frame = start_frame

func disconnect_signals() -> void:
	if _player.sprite.frame_changed.is_connected(_on_frame_changed):
		_player.sprite.frame_changed.disconnect(_on_frame_changed)
	if _player.sprite.frame_changed.is_connected(_on_transition_frame_changed):
		_player.sprite.frame_changed.disconnect(_on_transition_frame_changed)

func call_transition_inputs():
	get_root().input_for_run()
	get_root().input_for_idle()
	get_root().input_for_dash()
	get_root().input_for_parry()
	get_root().input_for_shield_block()
	get_root().input_for_combo_light_atk()
	get_root().input_for_heavy_atk()
	get_root().input_for_jump()
