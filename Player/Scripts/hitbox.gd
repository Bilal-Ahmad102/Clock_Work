extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var hitbox_damage: float = 0.0
var _hit_bodies: Array = []

func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_hitbox_body_entered)

func _setup_dash_shape() -> void:
	var dash_distance = PlayerData.DASH_SPEED * PlayerData.DASH_DURATION  # 180px
	dash_distance += dash_distance * .4
	var shape := RectangleShape2D.new()
	shape.size = Vector2(dash_distance, 32)  # 180 wide, 32 tall ; adjust height to player height
	collision_shape_2d.shape = shape
	collision_shape_2d.position = Vector2(90,-22)

func _on_hitbox_body_entered(body: Node) -> void:
	if body == get_tree().get_first_node_in_group("Player"):
		return
	if body in _hit_bodies:
		return
	if body.has_method("take_damage"):
		#var direction := Vector2(sign(body.global_position.x - global_position.x), -0.2).normalized()
		body.take_damage(hitbox_damage)

		_hit_bodies.append(body)


func change_direction(left:bool):

	if collision_shape_2d.position.x > 0:
		collision_shape_2d.position.x += collision_shape_2d.position.x * .3
	else:
		collision_shape_2d.position.x -= collision_shape_2d.position.x * .3
		
	if left:
		collision_shape_2d.position.x = -collision_shape_2d.position.x
		
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
