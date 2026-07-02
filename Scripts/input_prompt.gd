@tool
extends Sprite2D
## Floating input-prompt hint.
##
## Add an Area2D child (with a CollisionShape2D) whose collision mask includes
## the player's layer. When the player enters, the prompt fades in and gently
## bobs; on exit it fades out. The shown icon matches the input device the
## player last used (keyboard / Xbox / PlayStation), picked from the exported
## textures below.
##
## In the editor the prompt is drawn fully visible so it can be previewed;
## use "Preview Device" to see each device's texture. At runtime that setting
## is ignored — the real input device is detected instead.

enum Device { KEYBOARD, XBOX, PS4 }

@export var hint_text: String = "Jump":
	set(value):
		hint_text = value
		if is_node_ready():
			_apply_hint_text()

## Editor-only: which device's texture to show while previewing in the editor.
@export var preview_device: Device = Device.KEYBOARD:
	set(value):
		preview_device = value
		if Engine.is_editor_hint() and is_node_ready():
			_apply_texture()

@export var keyboard_texture: Texture2D:
	set(value):
		keyboard_texture = value
		if is_node_ready():
			_apply_texture()
@export var xbox_texture: Texture2D:
	set(value):
		xbox_texture = value
		if is_node_ready():
			_apply_texture()
@export var ps4_texture: Texture2D:
	set(value):
		ps4_texture = value
		if is_node_ready():
			_apply_texture()

@export_group("Layout")
## Top-left position of the hint text, in local (pre-scale) pixels.
## The script owns the Label's position — move it with this, not by dragging.
@export var text_position: Vector2 = Vector2(-128, -72):
	set(value):
		text_position = value
		if is_node_ready():
			_apply_text_position()
## Drawing offset of the button texture only (the text stays put),
## in local (pre-scale) pixels.
@export var button_offset: Vector2 = Vector2.ZERO:
	set(value):
		button_offset = value
		offset = value

@export_group("Float")
@export var bob_height: float = 4.0   ## pixels of vertical travel
@export var bob_speed: float = 3.0    ## bob cycles speed (radians/sec)
@export var fade_time: float = 0.15   ## show/hide fade duration (seconds)

var _device: Device = Device.KEYBOARD
var _base_y: float
var _time: float = 0.0
var _shown: bool = false

@onready var _label: Label = get_node_or_null("Label")

func _ready() -> void:
	_apply_hint_text()
	_apply_text_position()
	_apply_texture()
	offset = button_offset
	if Engine.is_editor_hint():
		visible = true
		modulate.a = 1.0
		return
	_base_y = position.y
	visible = false
	modulate.a = 0.0
	# Auto-wire the first Area2D child as the trigger volume.
	for child in get_children():
		if child is Area2D:
			child.body_entered.connect(_on_body_entered)
			child.body_exited.connect(_on_body_exited)
			break

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not _shown:
		return
	_time += delta * bob_speed
	position.y = _base_y + sin(_time) * bob_height

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	var new_device := _device
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		new_device = Device.KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		new_device = _gamepad_brand(event.device)
	if new_device != _device:
		_device = new_device
		_apply_texture()

## Guesses the controller family from its reported name; defaults to Xbox.
func _gamepad_brand(device_id: int) -> Device:
	var name := Input.get_joy_name(device_id).to_lower()
	for tag in ["ps", "playstation", "dualshock", "dualsense", "sony"]:
		if name.contains(tag):
			return Device.PS4
	return Device.XBOX

func _apply_texture() -> void:
	var device := preview_device if Engine.is_editor_hint() else _device
	var new_texture: Texture2D
	match device:
		Device.PS4:
			new_texture = ps4_texture
		Device.XBOX:
			new_texture = xbox_texture
		_:
			new_texture = keyboard_texture
	if new_texture != null:
		texture = new_texture

func _apply_hint_text() -> void:
	if _label != null:
		_label.text = hint_text

func _apply_text_position() -> void:
	if _label != null:
		_label.position = text_position

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	_shown = true
	visible = true
	_time = 0.0
	_apply_texture()
	create_tween().tween_property(self, "modulate:a", 1.0, fade_time)

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	_shown = false
	position.y = _base_y
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	tween.tween_callback(func() -> void: visible = false)
