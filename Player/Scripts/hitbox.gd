extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var hitbox_damage: float = 0.0
var _hit_bodies: Array = []
var atk_name : StringName

# atk_name → behaviour reading fired when this attack lands a hit.
# Each Callable records the pattern weight AND the repetition id.
# atk_name → behaviour reading fired when this attack lands a hit.
var _record_map : Dictionary = {
	&"combo_atk":       func(): Audience.record_precise_hit(1.0),
	&"heavy_atk":       func(): Audience.record_brutal_hit(1.5),
	&"sprint_atk":      func(): Audience.record_brutal_hit(1.0),
	&"magic_dash_atk":  func(): Audience.record_precise_hit(1.5),
	&"magic_heavy_atk": func(): Audience.record_brutal_hit(2.5),
}


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
		body.take_damage(hitbox_damage)
		_hit_bodies.append(body)
		_record_behaviour()

func _record_behaviour() -> void:
	if _record_map.has(atk_name):
		_record_map[atk_name].call()
	else:
		push_warning("No Audience record mapping for atk_name: " + str(atk_name))
	Audience.record_repeat_attack(atk_name)

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
		 

func _activate_hitbox(damage: float, incoming_atk_name:StringName) -> void:
	monitoring = true
	hitbox_damage = damage
	atk_name = incoming_atk_name
	_hit_bodies.clear()

func _deactivate_hitbox() -> void:
	monitoring = false
	_hit_bodies.clear()
