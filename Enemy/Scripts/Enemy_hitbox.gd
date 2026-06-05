extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var hitbox_damage: float = 0.0

func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_hitbox_body_entered)


func _on_hitbox_body_entered(body: Node) -> void:
	if body == get_tree().get_first_node_in_group("Player"):
		body.take_damage(hitbox_damage)


func change_direction(left:bool):

	if collision_shape_2d.position.x > 0:
		collision_shape_2d.position.x += collision_shape_2d.position.x * .3
	else:
		collision_shape_2d.position.x -= collision_shape_2d.position.x * .3
		
	if left:
		collision_shape_2d.position.x = -collision_shape_2d.position.x
		
func change_face(left:bool):
	if left:
		collision_shape_2d.position.x = -35
	else:
		collision_shape_2d.position.x = 35
		 

func _activate_hitbox(damage: float) -> void:
	monitoring = true
	hitbox_damage = damage

func _deactivate_hitbox() -> void:
	monitoring = false
