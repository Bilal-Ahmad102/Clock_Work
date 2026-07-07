class_name LoadingScreen
extends Control

## Threaded-load transition screen. Set `target_scene` (static), then
## change to this scene; it streams the target in the background, fills
## the progress bar, and swaps to the target when ready.
##
##     LoadingScreen.target_scene = "res://Scenes/intro_level.tscn"
##     get_tree().change_scene_to_file("res://Scenes/UI/loading_screen.tscn")

static var target_scene := "res://Scenes/intro_level.tscn"

## Minimum time the screen stays up, so short loads don't flash.
@export var min_show_time := 0.4

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var cog: Polygon2D = %Cog

var _elapsed := 0.0
var _progress := []


func _ready() -> void:
	ResourceLoader.load_threaded_request(target_scene)


func _process(delta: float) -> void:
	_elapsed += delta
	cog.rotation += delta * 3.0

	var status := ResourceLoader.load_threaded_get_status(target_scene, _progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = _progress[0] * 100.0
		ResourceLoader.THREAD_LOAD_LOADED:
			progress_bar.value = 100.0
			if _elapsed >= min_show_time:
				set_process(false)
				var packed: PackedScene = ResourceLoader.load_threaded_get(target_scene)
				get_tree().change_scene_to_packed(packed)
		_:
			push_error("LoadingScreen: failed to load '%s'" % target_scene)
			set_process(false)
			get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
