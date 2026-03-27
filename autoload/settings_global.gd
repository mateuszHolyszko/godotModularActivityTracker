extends Node

# Settings file path
const SETTINGS_PATH = "res://GMAT_settings.cfg"

# Configuration instance
var config = ConfigFile.new()

# Signal to notify when settings change
signal settings_changed
signal shader_toggled(shader_enabled: bool)
signal bleed_shader_updated(params: Dictionary)
signal crt_shader_updated(params: Dictionary)

# Default values
const DEFAULT_RESOLUTION = Vector2i(800, 480)
const DEFAULT_SHADER_TOGGLE = true
const DEFAULT_SHADER_TEXT_SCALE = 1  # 1 = full resolution, 2 = half resolution, etc.

# Bleed shader defaults (pixel_width will be calculated dynamically)
const DEFAULT_BLEED_SETTINGS = {
	"bleed_strength": 0.295,
	"brightness_threshold": 0.2,
	"shift_multiplier": 7.6
}

# CRT shader defaults (pixel_width and pixel_height will be calculated dynamically)
const DEFAULT_CRT_SETTINGS = {
	"intensity": 0.25,
	"scanline_thickness": 0.65,
	"scanline_darkness": 1.205,
	"phosphor_thickness": 1.375,
	"phosphor_strength": 0.15,
	"flicker_speed": 100.0,
	"flicker_strength": 0.03
}

# Stored for access in setting menu (for shader toggle)
var render_canvas_layer

func _ready():
	load_settings()

func load_settings():
	var err = config.load(SETTINGS_PATH)
	
	if err != OK:
		print("No settings file found. Creating defaults...")
		_set_defaults()
		save_settings()
	else:
		# Validate loaded settings have all required keys
		_validate_and_fix_settings()
	
	# Emit signals to update shaders after loading
	_emit_shader_signals()

func _set_defaults():
	# Video settings
	config.set_value("video", "resolution", DEFAULT_RESOLUTION)
	config.set_value("video", "shader_enabled", DEFAULT_SHADER_TOGGLE)
	config.set_value("video", "shader_text_scale", DEFAULT_SHADER_TEXT_SCALE)
	
	# Bleed shader settings (pixel_width will be calculated dynamically)
	for key in DEFAULT_BLEED_SETTINGS:
		config.set_value("bleed_shader", key, DEFAULT_BLEED_SETTINGS[key])
	
	# CRT shader settings (pixel_width and pixel_height will be calculated dynamically)
	for key in DEFAULT_CRT_SETTINGS:
		config.set_value("crt_shader", key, DEFAULT_CRT_SETTINGS[key])

func _validate_and_fix_settings():
	# Check and add missing video settings
	if not config.has_section_key("video", "resolution"):
		config.set_value("video", "resolution", DEFAULT_RESOLUTION)
	if not config.has_section_key("video", "shader_enabled"):
		config.set_value("video", "shader_enabled", DEFAULT_SHADER_TOGGLE)
	if not config.has_section_key("video", "shader_text_scale"):
		config.set_value("video", "shader_text_scale", DEFAULT_SHADER_TEXT_SCALE)
	
	# Check and add missing bleed shader settings
	for key in DEFAULT_BLEED_SETTINGS:
		if not config.has_section_key("bleed_shader", key):
			config.set_value("bleed_shader", key, DEFAULT_BLEED_SETTINGS[key])
	
	# Check and add missing CRT shader settings
	for key in DEFAULT_CRT_SETTINGS:
		if not config.has_section_key("crt_shader", key):
			config.set_value("crt_shader", key, DEFAULT_CRT_SETTINGS[key])

func _emit_shader_signals():
	# Emit signals with current settings
	shader_toggled.emit(get_shader_enabled())
	bleed_shader_updated.emit(get_all_bleed_settings())
	crt_shader_updated.emit(get_all_crt_settings())

# ========== HELPER FUNCTIONS ==========

func _calculate_pixel_dimensions() -> Vector2:
	"""Calculate pixel dimensions based on current resolution and text scale"""
	var resolution = get_resolution()
	var scale = get_shader_text_scale()
	
	# Ensure scale is at least 1
	scale = max(1, scale)
	
	return Vector2(resolution.x / scale, resolution.y / scale)

# ========== GETTERS ==========

func get_resolution() -> Vector2i:
	return config.get_value("video", "resolution", DEFAULT_RESOLUTION)

func get_shader_enabled() -> bool:
	return config.get_value("video", "shader_enabled", DEFAULT_SHADER_TOGGLE)

func get_shader_text_scale() -> int:
	return config.get_value("video", "shader_text_scale", DEFAULT_SHADER_TEXT_SCALE)

# Bleed shader getters
func get_bleed_strength() -> float:
	return config.get_value("bleed_shader", "bleed_strength", DEFAULT_BLEED_SETTINGS["bleed_strength"])

func get_bleed_pixel_width() -> float:
	# Calculate pixel width based on current resolution and scale
	var pixel_dimensions = _calculate_pixel_dimensions()
	return pixel_dimensions.x

func get_brightness_threshold() -> float:
	return config.get_value("bleed_shader", "brightness_threshold", DEFAULT_BLEED_SETTINGS["brightness_threshold"])

func get_shift_multiplier() -> float:
	return config.get_value("bleed_shader", "shift_multiplier", DEFAULT_BLEED_SETTINGS["shift_multiplier"])

func get_all_bleed_settings() -> Dictionary:
	var pixel_dimensions = _calculate_pixel_dimensions()
	return {
		"bleed_strength": get_bleed_strength(),
		"pixel_width": pixel_dimensions.x,
		"brightness_threshold": get_brightness_threshold(),
		"shift_multiplier": get_shift_multiplier()
	}

# CRT shader getters
func get_crt_intensity() -> float:
	return config.get_value("crt_shader", "intensity", DEFAULT_CRT_SETTINGS["intensity"])

func get_crt_pixel_width() -> float:
	# Calculate pixel width based on current resolution and scale
	var pixel_dimensions = _calculate_pixel_dimensions()
	return pixel_dimensions.x

func get_crt_pixel_height() -> float:
	# Calculate pixel height based on current resolution and scale
	var pixel_dimensions = _calculate_pixel_dimensions()
	return pixel_dimensions.y

func get_scanline_thickness() -> float:
	return config.get_value("crt_shader", "scanline_thickness", DEFAULT_CRT_SETTINGS["scanline_thickness"])

func get_scanline_darkness() -> float:
	return config.get_value("crt_shader", "scanline_darkness", DEFAULT_CRT_SETTINGS["scanline_darkness"])

func get_phosphor_thickness() -> float:
	return config.get_value("crt_shader", "phosphor_thickness", DEFAULT_CRT_SETTINGS["phosphor_thickness"])

func get_phosphor_strength() -> float:
	return config.get_value("crt_shader", "phosphor_strength", DEFAULT_CRT_SETTINGS["phosphor_strength"])

func get_flicker_speed() -> float:
	return config.get_value("crt_shader", "flicker_speed", DEFAULT_CRT_SETTINGS["flicker_speed"])

func get_flicker_strength() -> float:
	return config.get_value("crt_shader", "flicker_strength", DEFAULT_CRT_SETTINGS["flicker_strength"])

func get_all_crt_settings() -> Dictionary:
	var pixel_dimensions = _calculate_pixel_dimensions()
	return {
		"intensity": get_crt_intensity(),
		"pixel_width": pixel_dimensions.x,
		"pixel_height": pixel_dimensions.y,
		"scanline_thickness": get_scanline_thickness(),
		"scanline_darkness": get_scanline_darkness(),
		"phosphor_thickness": get_phosphor_thickness(),
		"phosphor_strength": get_phosphor_strength(),
		"flicker_speed": get_flicker_speed(),
		"flicker_strength": get_flicker_strength()
	}

# ========== SETTERS ==========

func set_resolution(resolution: Vector2i):
	config.set_value("video", "resolution", resolution)
	save_settings()
	# When resolution changes, pixel dimensions update automatically
	# Emit shader updates with new pixel dimensions
	bleed_shader_updated.emit(get_all_bleed_settings())
	crt_shader_updated.emit(get_all_crt_settings())
	settings_changed.emit()

func set_shader_enabled(enabled: bool):
	config.set_value("video", "shader_enabled", enabled)
	save_settings()
	shader_toggled.emit(enabled)
	settings_changed.emit()

func set_shader_text_scale(scale: int):
	# Ensure scale is at least 1
	scale = max(1, scale)
	config.set_value("video", "shader_text_scale", scale)
	save_settings()
	# When scale changes, pixel dimensions update automatically
	# Emit shader updates with new pixel dimensions
	bleed_shader_updated.emit(get_all_bleed_settings())
	crt_shader_updated.emit(get_all_crt_settings())
	settings_changed.emit()

# Bleed shader setters
func set_bleed_strength(value: float):
	config.set_value("bleed_shader", "bleed_strength", clamp(value, 0.0, 2.0))
	save_settings()
	bleed_shader_updated.emit(get_all_bleed_settings())
	settings_changed.emit()

func set_brightness_threshold(value: float):
	config.set_value("bleed_shader", "brightness_threshold", clamp(value, 0.0, 1.0))
	save_settings()
	bleed_shader_updated.emit(get_all_bleed_settings())
	settings_changed.emit()

func set_shift_multiplier(value: float):
	config.set_value("bleed_shader", "shift_multiplier", clamp(value, 1.0, 16.0))
	save_settings()
	bleed_shader_updated.emit(get_all_bleed_settings())
	settings_changed.emit()

# CRT shader setters
func set_crt_intensity(value: float):
	config.set_value("crt_shader", "intensity", value)
	save_settings()
	crt_shader_updated.emit(get_all_crt_settings())
	settings_changed.emit()

func set_scanline_thickness(value: float):
	config.set_value("crt_shader", "scanline_thickness", clamp(value, 0.5, 0.9))
	save_settings()
	crt_shader_updated.emit(get_all_crt_settings())
	settings_changed.emit()

func set_scanline_darkness(value: float):
	config.set_value("crt_shader", "scanline_darkness", clamp(value, 0.1, 1.5))
	save_settings()
	crt_shader_updated.emit(get_all_crt_settings())
	settings_changed.emit()

func set_phosphor_thickness(value: float):
	config.set_value("crt_shader", "phosphor_thickness", clamp(value, 1.5, 3.0))
	save_settings()
	crt_shader_updated.emit(get_all_crt_settings())
	settings_changed.emit()

func set_phosphor_strength(value: float):
	config.set_value("crt_shader", "phosphor_strength", clamp(value, 0.05, 0.25))
	save_settings()
	crt_shader_updated.emit(get_all_crt_settings())
	settings_changed.emit()

func set_flicker_speed(value: float):
	config.set_value("crt_shader", "flicker_speed", clamp(value, 40.0, 150.0))
	save_settings()
	crt_shader_updated.emit(get_all_crt_settings())
	settings_changed.emit()

func set_flicker_strength(value: float):
	config.set_value("crt_shader", "flicker_strength", clamp(value, 0.01, 0.05))
	save_settings()
	crt_shader_updated.emit(get_all_crt_settings())
	settings_changed.emit()

func save_settings():
	config.save(SETTINGS_PATH)
