class_name Menu
extends RefCounted

# ─── Signals ────────────────────────────────────────────────
signal load_progress_changed(progress: float)   # 0.0 – 1.0
signal load_completed(scene: PackedScene)
signal load_failed(path: String)

# ─── Properties ─────────────────────────────────────────────
var name: String
var scene_path: String

var is_loading: bool = false
var is_loaded: bool = false
var load_progress: float = 0.0
var is_persistent: bool = false

var _packed_scene: PackedScene = null
var _thread: Thread = null
var _instance: Node = null  # Cached live instance for persistent menus


# ─── Constructor ─────────────────────────────────────────────
func _init(p_name: String, p_scene_path: String, p_persistent: bool = false) -> void:
	name = p_name
	scene_path = p_scene_path
	is_persistent = p_persistent


# ─── Public API ──────────────────────────────────────────────

func get_scene() -> PackedScene:
	return _packed_scene

func instantiate() -> Node:
	if _packed_scene == null:
		push_warning("Menu '%s': tried to instantiate before loading." % name)
		return null
	return _packed_scene.instantiate()

## Returns the cached instance for persistent menus, or a fresh one otherwise.
## Caller is responsible for adding it to the scene tree if newly created.
func get_or_instantiate() -> Node:
	if is_persistent:
		if _instance == null:
			_instance = instantiate()
		return _instance
	return instantiate()

## Call this if a persistent menu's instance is removed from the tree externally.
func clear_instance() -> void:
	_instance = null

func preload_scene() -> void:
	if is_loaded:
		load_completed.emit(_packed_scene)
		return
	if is_loading:
		return

	is_loading = true
	load_progress = 0.0
	_thread = Thread.new()
	_thread.start(_load_on_thread)

func unload() -> void:
	_packed_scene = null
	is_loaded = false
	load_progress = 0.0


# ─── Private ─────────────────────────────────────────────────

func _load_on_thread() -> void:
	var scene := ResourceLoader.load(scene_path) as PackedScene
	_packed_scene = scene
	_thread.call_deferred("wait_to_finish")
	if scene == null:
		call_deferred("_finish_failed")
	else:
		call_deferred("_finish_loaded")

func _finish_loaded() -> void:
	is_loading = false
	is_loaded = true
	load_progress = 1.0
	load_progress_changed.emit(1.0)
	load_completed.emit(_packed_scene)

func _finish_failed() -> void:
	is_loading = false
	push_error("Menu '%s': failed to load '%s'." % [name, scene_path])
	load_failed.emit(scene_path)
