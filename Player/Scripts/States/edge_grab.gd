extends LimboState


@onready var debug: Label = %debug

var _player: CharacterBody2D
var sprite : AnimatedSprite2D
const to_edge_grab   =  &"to_edge_grab"
const edge_grab      =  &"edge_grab"
const edge_grab_fall =  &"edge_grab_fall"
const edge_grab_pull =  &"edge_grab_pull"
const edge_grab_land =  &"edge_grab_land"

var current_animation : StringName
var pulling : bool = false
var falling : bool = false
var sprite_tween : TweenComposer 
var player_tween : TweenComposer 
var tween_time: float = .4
func _setup() -> void:
	_player = agent  # agent = the CharacterBody2D passed to hsm.initialize()
func _enter() -> void:

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
		_player.sprite.offset = Vector2(-2, -21)
		sprite.position = Vector2.ZERO
		get_root().dispatch(&"idle")
	elif current_animation == edge_grab_land:
		_player.full_stop_movement(false)
		get_root().dispatch(&"idle")
		
func _exit() -> void:
	_player.full_stop_movement(false)
	get_root().previous_state = self
	pulling = false
	falling = false
	
	#player_tween_composer.reset_tween()
	#sprite_tween_composer.reset_tween()
	
	sprite.animation_finished.disconnect(_on_animation_finished)
	if player_tween: player_tween.queue_free()
	if sprite_tween: sprite_tween.queue_free()
func _update(delta: float) -> void:
	if _player.is_on_floor() and current_animation == edge_grab_fall:
		sprite.play(edge_grab_land)
		current_animation = edge_grab_land
	if falling:
		_player.apply_gravity(delta)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and !pulling:
		pulling = true
		if agent.sprite.flip_h: _player.sprite.offset = Vector2(-7,-28)
		else:_player.sprite.offset = Vector2(7,-28)
		sprite.play(edge_grab_pull)
		player_tween = TweenComposer.new()
		sprite_tween = TweenComposer.new() 

		_player.add_child(player_tween)
		sprite.add_child(sprite_tween)
		
		
		var player_tween_res_r : Resource = load("res://Resources/tweens/player_position_edge_pull.tres")
		var sprite_tween_res_r : Resource = load("res://Resources/tweens/player_sprite_position_edge_pull.tres")

		var player_tween_res_l : Resource = load("res://Resources/tweens/player_position_edge_pull_left.tres")
		var sprite_tween_res_l : Resource = load("res://Resources/tweens/player_sprite_position_edge_pull_left.tres")

		player_tween_res_r.tween_duration = tween_time
		sprite_tween_res_r.tween_duration = tween_time
		player_tween_res_l.tween_duration = tween_time
		sprite_tween_res_l.tween_duration = tween_time



		
		
		if _player.facing_left:
			player_tween.load_tween_sequence(player_tween_res_l)
			sprite_tween.load_tween_sequence(sprite_tween_res_l)
		else:
			player_tween.load_tween_sequence(player_tween_res_r)
			sprite_tween.load_tween_sequence(sprite_tween_res_r)




		player_tween.play_tween()
		sprite_tween.play_tween()

		current_animation = edge_grab_pull
	elif event.is_action_pressed("dash") and !falling:
		falling = true
		sprite.play(edge_grab_fall)
		current_animation = edge_grab_fall
