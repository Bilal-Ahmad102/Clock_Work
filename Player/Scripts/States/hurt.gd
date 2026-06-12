extends LimboState

var _player: CharacterBody2D
var sprite: AnimatedSprite2D

func _setup() -> void:
	_player = agent
func _enter() -> void:
	
	sprite = _player.sprite
	sprite.play(&"hurt")
	sprite.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished() -> void:
	get_root().dispatch(&"idle")

func _exit() -> void:

	if sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.disconnect(_on_animation_finished)
	
	get_root().previous_state = self
	
func _update(delta: float) -> void:
	_player.apply_gravity(delta)
