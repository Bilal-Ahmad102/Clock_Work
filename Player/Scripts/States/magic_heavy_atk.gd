extends LimboState

var _player: CharacterBody2D
@onready var hitbox: Area2D = %hitbox
func _setup() -> void:
	_player = agent 

func _enter() -> void:
	if agent.sprite.flip_h: _player.sprite.offset = Vector2(-12,-51)
	else:                 _player.sprite.offset = Vector2(12,-51)

	_player.play_anim(&"magic_heavy_atk")
	_player.full_stop_movement(true)


	# Spend stamina
	PlayerData.spend_mana(PlayerData.MAGIC_DASH_MANA_COST)
	_player.sprite.frame_changed.connect(_on_combo_frame_changed)

func _on_combo_frame_changed() -> void:
	match _player.sprite.frame:
		# hit frames for each combo stage ; adjust to your spritesheet
		17: hitbox._activate_hitbox(PlayerData.MAGIC_HEAVY_ATTACK_DAMAGE,self.name)
		_:                       hitbox._deactivate_hitbox()

func _exit() -> void:
	if _player.sprite.frame_changed.is_connected(_on_combo_frame_changed):
		_player.sprite.frame_changed.disconnect(_on_combo_frame_changed)
	_player.full_stop_movement(false)
	_player.sprite.offset = Vector2(-2,-21)

	get_root().previous_state = self

func _on_animation_finished() -> void:
	if !get_root().input_for_walk():
		get_root().dispatch(&"idle")
		
	elif !get_root().input_for_walk() \
		and get_root().previous_state == get_root().walk:
		get_root().dispatch(&"walk")
