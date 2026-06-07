extends Node2D

@onready var chest_ray: RayCast2D = %chest_ray
@onready var head_ray: RayCast2D = %head_ray

var _chest_origin: Vector2
var _head_origin: Vector2

func _ready() -> void:
	_chest_origin = chest_ray.position
	_head_origin  = head_ray.position

func flip_rays(dir_left: bool) -> void:
	if dir_left:
		rotation = deg_to_rad(180)
		chest_ray.position = _head_origin
		head_ray.position  = _chest_origin
	else:
		rotation = deg_to_rad(0)
		chest_ray.position = _chest_origin
		head_ray.position  = _head_origin
