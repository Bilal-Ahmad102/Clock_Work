extends LimboState

@onready var debug: Label = %debug

var _player: CharacterBody2D

func _setup() -> void:
	_player = agent  # agent = the CharacterBody2D passed to hsm.initialize()

func _enter() -> void:

	play_anim_then_loop(&"idle_jump",2,4)

	
func _exit() -> void:
	get_root().previous_state = self
	disconnect_signals()

func _on_animation_finished() -> void:
	get_root().dispatch(&"idle")
	
func _update(delta: float) -> void:

	if _player.sprite.frame <= 9  :
		play_anim_interval(&"combo_atk",10,15,true)
	elif _player.sprite.frame > 9 and _player.sprite.frame <= 15 :
		play_anim_interval(&"combo_atk",15,29,true)

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

func play_anim_interval(anim: StringName, start_frame: int, end_frame: int, _combo_requested: bool = false) -> void:
	if !agent.sprite.frame_changed.is_connected(_on_frame_changed_for_interval):
		agent.sprite.frame_changed.connect(_on_frame_changed_for_interval)

func _on_frame_changed_for_interval() -> void:
	agent.sprite.frame_changed.disconnect(_on_frame_changed_for_interval)
func disconnect_signals() -> void:
	if _player.sprite.frame_changed.is_connected(_on_frame_changed_for_interval):
		_player.sprite.frame_changed.disconnect(_on_frame_changed_for_interval)
		
