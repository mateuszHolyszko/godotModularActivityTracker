extends Node

# ─── Signals ────────────────────────────────────────────────
signal load_progress_changed(progress: float)   # 0.0 – 1.0
signal load_completed(scenes: Array)            # Array[PackedScene]
signal load_failed(path: String)

# ─── Config ─────────────────────────────────────────────────
var scene_paths := [
	"res://scenes/3d/scene_whole_body.tscn",
	"res://scenes/3d/scene_arms.tscn",
	"res://scenes/3d/scene_legs.tscn",
]

# ─── State ──────────────────────────────────────────────────
var is_loading: bool = false
var is_loaded: bool = false
var load_progress: float = 0.0

var _scenes: Array = []              # Array[PackedScene]
var _thread: Thread = null


# ─── Public API ──────────────────────────────────────────────

func get_scenes() -> Array:
	return _scenes

func preload_scenes() -> void:
	if is_loaded:
		load_completed.emit(_scenes)
		return
	if is_loading:
		return

	is_loading = true
	load_progress = 0.0
	_scenes.clear()

	_thread = Thread.new()
	_thread.start(_load_on_thread)

func unload() -> void:
	_scenes.clear()
	is_loaded = false
	load_progress = 0.0


# ─── Private ─────────────────────────────────────────────────

func _load_on_thread() -> void:
	var loaded_scenes: Array = []

	for i in range(scene_paths.size()):
		var path = scene_paths[i]
		var scene := ResourceLoader.load(path) as PackedScene

		if scene == null:
			call_deferred("_finish_failed", path)
			return

		loaded_scenes.append(scene)

		# update progress
		var progress = float(i + 1) / scene_paths.size()
		call_deferred("_update_progress", progress)

	_scenes = loaded_scenes
	_thread.call_deferred("wait_to_finish")
	call_deferred("_finish_loaded")


func _update_progress(p: float) -> void:
	load_progress = p
	load_progress_changed.emit(p)


func _finish_loaded() -> void:
	is_loading = false
	is_loaded = true
	load_progress = 1.0

	load_progress_changed.emit(1.0)
	load_completed.emit(_scenes)


func _finish_failed(path: String) -> void:
	is_loading = false
	push_error("SceneRegistry: failed to load '%s'." % path)
	load_failed.emit(path)
