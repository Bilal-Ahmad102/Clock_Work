class_name Teleporter
extends Node2D

## Two-sided teleporter. Drop two instances into a level and point each
## one's `linked` export at the other. While the player stands in the
## trigger, pressing "interact" (E / Xbox X / PS Square) moves them to the
## linked side's exit_point. A short cooldown on the receiving side stops
## the same press from bouncing the player straight back.

@export var linked: Teleporter
## Seconds the receiving side ignores interact after an arrival.
@export var cooldown := 0.4

@onready var exit_point: Marker2D = $exit_point
@onready var trigger: Area2D = $trigger

var _player: CharacterBody2D
var _cooldown_left := 0.0


func _ready() -> void:
	trigger.body_entered.connect(_on_body_entered)
	trigger.body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	if _cooldown_left > 0.0:
		_cooldown_left -= delta
		return
	if _player == null or linked == null:
		return
	if Input.is_action_just_pressed(&"teleport"):
		_teleport()


func _teleport() -> void:
	linked._cooldown_left = linked.cooldown
	_player.global_position = linked.exit_point.global_position
	_player.velocity = Vector2.ZERO
	if "camera" in _player and _player.camera is PlayerCamera:
		_player.camera.snap_to_target()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player = body


func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
