extends PanelContainer

## Shared options panel (instanced by both the main menu and the pause
## menu): master volume + fullscreen toggle. Emits `closed` on Back;
## the host menu decides what to show again.

signal closed

@onready var volume_slider: HSlider = %VolumeSlider
@onready var fullscreen_check: CheckButton = %FullscreenCheck
@onready var back_button: Button = %BackButton


func _ready() -> void:
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.button_pressed = (
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(func() -> void: closed.emit())


func focus_first() -> void:
	volume_slider.grab_focus()


func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(value, 0.0001)))
	AudioServer.set_bus_mute(0, value <= 0.001)


func _on_fullscreen_toggled(on: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED
	)
