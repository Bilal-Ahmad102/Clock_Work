## Walk.gd
extends LimboState

var _player: CharacterBody2D
var request_for_idle: bool = false
func _setup() -> void:
	_player = agent

func _enter() -> void:

	if get_root().previous_state == get_root().idle:
		play_anim_then_loop("shield_block",4,7)
	else:
		play_anim_looped("shield_block",4,7)
	_player.full_stop_movement(true)

func _exit() -> void:
	_player.full_stop_movement(false)
	request_for_idle = false
	get_root().previous_state = self

func _on_animation_finished() -> void:
	get_root().dispatch("idle")
	get_root().previous_state = self

func _update(delta: float) -> void:
	if !get_root().input_for_shield_block() and !request_for_idle:
		request_for_idle = true
		play_anim_rest("shield_block",7)

	call_transition_inputs()
	

func play_anim_rest(anim: StringName, _start_frame: int) -> void:
	if _player.sprite.frame_changed.is_connected(_on_frame_changed):
		_player.sprite.frame_changed.disconnect(_on_frame_changed)
	_player.sprite.frame = _start_frame
	_player.sprite.play(anim)
	
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

func call_transition_inputs():
	get_root().input_for_parry()
