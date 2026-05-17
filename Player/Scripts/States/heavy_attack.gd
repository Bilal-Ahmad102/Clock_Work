extends LimboState

var _player: CharacterBody2D
@onready var hitbox: Area2D = %hitbox
func _setup() -> void:
	_player = agent 

func _enter() -> void:
	_player.play_anim(&"heavy_atk")
	_player.full_stop_movement(true)
	_player.sprite.frame_changed.connect(_on_combo_frame_changed)

func _on_combo_frame_changed() -> void:
	match _player.sprite.frame:
		# hit frames for each combo stage ; adjust to your spritesheet
		7,8,9,10,11:  hitbox._activate_hitbox(PlayerData.HEAVY_ATTACK_DAMAGE)
		_:            hitbox._deactivate_hitbox()

func _exit() -> void:	

	if _player.sprite.frame_changed.is_connected(_on_combo_frame_changed):
		_player.sprite.frame_changed.disconnect(_on_combo_frame_changed)

	_player.full_stop_movement(false)
	get_root().previous_state = self

func _on_animation_finished() -> void:
	if !get_root().input_for_walk():
		get_root().dispatch(&"idle")
		
	elif !get_root().input_for_walk() \
		and get_root().previous_state == get_root().walk:
		get_root().dispatch(&"walk")
		
	
		
	get_root().previous_state = self

func play_FX():
	agent.fx_player.play(&"heavy_atk")
