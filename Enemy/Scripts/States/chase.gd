# chase.gd
extends LimboState
var _enemy: CharacterBody2D

func _setup() -> void:
	_enemy = agent

func _enter() -> void:
	_enemy.sprite.play("walk")
	
@warning_ignore("unused_parameter")
func _update(delta: float) -> void:
	if not _enemy.player:
		get_root().dispatch(&"idle")
		return
	var dir = (_enemy.player.global_position - _enemy.global_position).normalized()
	_enemy.velocity.x = dir.x * _enemy.move_speed
	_enemy.face_player()
	if _enemy.player_in_attack_zone:
		get_root().dispatch(&"attack")
	if not _enemy.detection_zone.has_overlapping_bodies():
		get_root().dispatch(&"idle")
