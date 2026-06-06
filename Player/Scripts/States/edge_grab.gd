extends LimboState


@onready var debug: Label = %debug
@onready var sprite_tween_composer: TweenComposer = $"../../AnimatedSprite2D/sprite_tween_composer"
@onready var player_tween_composer: TweenComposer = $"../../player_tween_composer"

var _player: CharacterBody2D
var sprite : AnimatedSprite2D
const to_edge_grab   =  &"to_edge_grab"
const edge_grab      =  &"edge_grab"
const edge_grab_fall =  &"edge_grab_fall"
const edge_grab_pull =  &"edge_grab_pull"
var current_animation : StringName

func _setup() -> void:
	_player = agent  # agent = the CharacterBody2D passed to hsm.initialize()
func _enter() -> void:
	#if agent.sprite.flip_h: _player.sprite.offset = Vector2(-20,-30)
	#else:                 _player.sprite.offset   = Vector2(20,-30)

	sprite = _player.sprite
	sprite.play(to_edge_grab)
	current_animation = to_edge_grab
	_player.full_stop_movement(true)
	if !sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	if current_animation == to_edge_grab:
		sprite.play(edge_grab)
		current_animation = edge_grab
	elif current_animation == edge_grab_pull:
		#_player.sprite.offset = Vector2(-2, -21)
		get_root().dispatch(&"idle")

func _exit() -> void:
	_player.full_stop_movement(false)
	get_root().previous_state = self
	sprite.animation_finished.disconnect(_on_animation_finished)
func _update(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		if agent.sprite.flip_h: _player.sprite.offset = Vector2(-10,-28)
		else:                 _player.sprite.offset   = Vector2(10,-28)

		sprite.play(edge_grab_pull)
		player_tween_composer.load_tween_sequence_and_start(
			load("res://Resources/player_position_edge_pull.tres")
		)
		sprite_tween_composer.load_tween_sequence_and_start(
			load("res://Resources/player_sprite_position_edge_pull.tres")
		)

		current_animation = edge_grab_pull
