class_name SpriteFramesBuilder
extends RefCounted

static func build_player_frames(folder: String, frame_size: Vector2i) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")

	_add_sheet(frames, &"idle", folder + "/Idle (32x32).png", frame_size, 8.0, true)
	_add_sheet(frames, &"run", folder + "/Run (32x32).png", frame_size, 12.0, true)
	_add_sheet(frames, &"jump", folder + "/Jump (32x32).png", frame_size, 5.0, false)
	_add_sheet(frames, &"fall", folder + "/Fall (32x32).png", frame_size, 5.0, false)
	_add_sheet(frames, &"hit", folder + "/Hit (32x32).png", frame_size, 10.0, false)
	if ResourceLoader.exists(folder + "/Double Jump (32x32).png"):
		_add_sheet(frames, &"double_jump", folder + "/Double Jump (32x32).png", frame_size, 10.0, false)

	return frames


static func build_enemy_frames(folder: String, frame_size: Vector2i, idle_name: String = "Idle", run_name: String = "Run", hit_name: String = "Hit") -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")

	var idle_path := _find_anim(folder, idle_name)
	var run_path := _find_anim(folder, run_name)
	var hit_path := _find_anim(folder, hit_name)

	if idle_path != "":
		_add_sheet(frames, &"idle", idle_path, frame_size, 8.0, true)
	if run_path != "":
		_add_sheet(frames, &"run", run_path, frame_size, 10.0, true)
	if hit_path != "":
		_add_sheet(frames, &"hit", hit_path, frame_size, 8.0, false)

	return frames


static func build_boss_frames(folder: String) -> SpriteFrames:
	return build_enemy_frames(folder, Vector2i(52, 34), "Idle", "Run", "Hit")


static func _find_anim(folder: String, prefix: String) -> String:
	var dir := DirAccess.open(folder)
	if dir == null:
		return ""
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.begins_with(prefix) and file_name.ends_with(".png"):
			dir.list_dir_end()
			return folder + "/" + file_name
		file_name = dir.get_next()
	dir.list_dir_end()
	return ""


static func _add_sheet(frames: SpriteFrames, anim_name: StringName, path: String, frame_size: Vector2i, fps: float, loop: bool) -> void:
	if not ResourceLoader.exists(path):
		return
	var texture: Texture2D = load(path)
	if texture == null:
		return

	var columns := maxi(1, texture.get_width() / frame_size.x)
	frames.add_animation(anim_name)
	frames.set_animation_speed(anim_name, fps)
	frames.set_animation_loop(anim_name, loop)

	for i in columns:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i * frame_size.x, 0, frame_size.x, frame_size.y)
		frames.add_frame(anim_name, atlas)
