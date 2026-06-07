extends LimboState

@onready var debug: Label = %debug
@onready var hitbox: Area2D = %hitbox

var _player: CharacterBody2D
var combo_atk : int = 0
var can_check_for_walk:bool = false
var combo_requested: bool = false
var combo_anim_interval: Vector2 = Vector2.ZERO
var combo_anim: StringName = ""

func _setup() -> void:
	_player = agent  # agent = the CharacterBody2D passed to hsm.initialize()

func _enter() -> void:
	if agent.sprite.flip_h: _player.sprite.offset = Vector2(-20,-30)
	else:                 _player.sprite.offset   = Vector2(20,-30)

	play_anim_interval(&"combo_atk",1,9)
	_player.full_stop_movement(true)

	_player.sprite.frame_changed.connect(_on_combo_frame_changed)

func _on_combo_frame_changed() -> void:
	match _player.sprite.frame:
		# hit frames for each combo stage ; adjust to your spritesheet
		4,6,7,8:            hitbox._activate_hitbox(PlayerData.LIGHT_ATTACK_DAMAGE_COMBO_1)
		11,12,13,14:        hitbox._activate_hitbox(PlayerData.LIGHT_ATTACK_DAMAGE_COMBO_2)
		18,19,20,21,22,23:  hitbox._activate_hitbox(PlayerData.LIGHT_ATTACK_DAMAGE_COMBO_3)
		_:                  hitbox._deactivate_hitbox()

func _exit() -> void:
	combo_atk = 0
	combo_requested = false
	combo_anim_interval = Vector2.ZERO
	_player.sprite.offset = Vector2(-2,-21)
	_player.full_stop_movement(false)
	get_root().previous_state = self
	disconnect_signals()

func _on_animation_finished() -> void:
	get_root().dispatch(&"idle")
@warning_ignore("unused_parameter")
func _update(delta: float) -> void:
	debug.add_debug(combo_atk)
	if Input.is_action_just_pressed("combo_atk") and combo_atk <= 2 :
		if _player.sprite.frame <= 9 and combo_atk == 0 :
			combo_atk += 1
			play_anim_interval(&"combo_atk",10,15,true)
		elif _player.sprite.frame > 9 and _player.sprite.frame <= 15 and combo_atk == 1 :
			combo_atk += 1
			play_anim_interval(&"combo_atk",15,29,true)

func play_anim_interval(anim: StringName, start_frame: int, end_frame: int, _combo_requested: bool = false) -> void:
	combo_anim = anim
	combo_requested = _combo_requested
	combo_anim_interval = Vector2(start_frame, end_frame)
	if !agent.sprite.frame_changed.is_connected(_on_frame_changed_for_interval):
		agent.sprite.frame_changed.connect(_on_frame_changed_for_interval)
	if !combo_requested:
		agent.play_anim(anim)

func _on_frame_changed_for_interval() -> void:
	if agent.sprite.frame > combo_anim_interval.y:
		if combo_requested:
			combo_requested = false
			agent.sprite.frame_changed.disconnect(_on_frame_changed_for_interval)
			play_anim_interval(combo_anim, int(combo_anim_interval.x), int(combo_anim_interval.y), false)
		else:
			agent.sprite.frame_changed.disconnect(_on_frame_changed_for_interval)
			combo_anim_interval = Vector2.ZERO
			get_root().dispatch(&"idle")
func disconnect_signals() -> void:
	if _player.sprite.frame_changed.is_connected(_on_frame_changed_for_interval):
		_player.sprite.frame_changed.disconnect(_on_frame_changed_for_interval)
		
	if _player.sprite.frame_changed.is_connected(_on_combo_frame_changed):
		_player.sprite.frame_changed.disconnect(_on_combo_frame_changed)
