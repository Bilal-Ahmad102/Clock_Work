extends LimboState

var _player: CharacterBody2D
@onready var hitbox: Area2D = %hitbox
func _setup() -> void:
	_player = agent  # agent = the CharacterBody2D passed to hsm.initialize()

func _enter() -> void:
	_player.sprite.offset.y -= 7
	_player.play_anim(&"sprint_attack")
	_player.velocity.y = PlayerData.JUMP_VELOCITY +  150
	_player.sprite.frame_changed.connect(_on_combo_frame_changed)

func _on_combo_frame_changed() -> void:
	match _player.sprite.frame:
		# hit frames for each combo stage ; adjust to your spritesheet
		4,5,6,7: hitbox._activate_hitbox(PlayerData.MAGIC_HEAVY_ATTACK_DAMAGE)
		_:                       hitbox._deactivate_hitbox()

func _exit() -> void:
	if _player.sprite.frame_changed.is_connected(_on_combo_frame_changed):
		_player.sprite.frame_changed.disconnect(_on_combo_frame_changed)
	_player.sprite.offset.y += 7
	
	get_root().previous_state = self
	
func _on_animation_finished() -> void:
	get_root().dispatch("run")
	get_root().previous_state = self

func _update(delta: float) -> void:
	_player.apply_gravity(delta)
