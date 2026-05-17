extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var hitbox_damage: float = 0.0
var _hit_bodies: Array = []

func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_hitbox_body_entered)

func _on_hitbox_body_entered(body: Node) -> void:
	if body == self:
		return
	if body in _hit_bodies:
		return
	print(_hit_bodies)
	#if _hit_bodies.is_empty(): return
	if body.has_method("take_damage"):
		#var direction := Vector2(sign(body.global_position.x - global_position.x), -0.2).normalized()
		body.take_damage(hitbox_damage)

		_hit_bodies.append(body)

func change_face(left:bool):
	if left:
		collision_shape_2d.position.x = -40
	else:
		collision_shape_2d.position.x = 40
		 

func _activate_hitbox(damage: float) -> void:
	monitoring = true
	hitbox_damage = damage
	_hit_bodies.clear()

func _deactivate_hitbox() -> void:
	monitoring = false
	_hit_bodies.clear()
