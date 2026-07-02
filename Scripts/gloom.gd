extends ColorRect
## Drives gloom.gdshader: keeps the light halo centred on `target` (the player)
## by converting its world position into screen-space UV every frame.

@export var target: Node2D            ## The player (or whatever should stay lit)
@export var light_radius: float = 220.0
@export var light_softness: float = 160.0

var _mat: ShaderMaterial

func _ready() -> void:
	_mat = material as ShaderMaterial
	# Cover the whole viewport and never eat input.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Fall back to the player if no target was wired in the scene.
	if target == null:
		target = get_tree().get_first_node_in_group(&"Player") as Node2D

func _process(_delta: float) -> void:
	if _mat == null or target == null:
		return
	var vp := get_viewport()
	var vp_size := vp.get_visible_rect().size
	# world -> screen pixels -> UV
	var screen_pos := vp.get_canvas_transform() * target.global_position
	_mat.set_shader_parameter("light_pos", screen_pos / vp_size)
	_mat.set_shader_parameter("viewport_size", vp_size)
	_mat.set_shader_parameter("light_radius", light_radius)
	_mat.set_shader_parameter("light_softness", light_softness)
