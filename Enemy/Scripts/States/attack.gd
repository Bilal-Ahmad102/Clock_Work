
extends LimboState

var _enemy:   CharacterBody2D
var _timer:   float = 0.0
var _attacked: bool  = false
var sprite : AnimatedSprite2D
func _setup() -> void:
	_enemy = agent

func _enter() -> void:
	_enemy.velocity.x = 0.0
	_timer    = _enemy.attack_cooldown
	_attacked = false
	_enemy.face_player()
	sprite = _enemy.sprite
	_do_attack()
	sprite.frame_changed.connect(_on_atk_frame_changed)

func _on_atk_frame_changed() -> void:
	if sprite.frame == 3:
		if _enemy.player_in_attack_zone and _enemy.player:
			_enemy.player.take_damage(20)
	
func _do_attack() -> void:
	_attacked = true
	# randomly pick light or heavy
	if randf() < 0.6:
		sprite.play("light_atk")
	else:
		sprite.play("heavy_atk")

func _exit() -> void:
	if sprite.frame_changed.is_connected(_on_atk_frame_changed):
		sprite.frame_changed.disconnect(_on_atk_frame_changed)
	get_root().previous_state = self

func _update(delta: float) -> void:
	_timer -= delta
	_enemy.face_player()

	if _timer <= 0.0:
		get_root().dispatch(&"recover")

func _on_animation_finished() -> void:
	if not _attacked:
		_do_attack()
