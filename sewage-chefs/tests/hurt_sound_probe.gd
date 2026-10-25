extends SceneTree

# Run with: Godot --headless --path . --script res://tests/hurt_sound_probe.gd
var failures: int = 0

func _initialize() -> void:
	call_deferred("run_probe")

func run_probe() -> void:
	# Capture just the hurt sound to check that playback produces actual audio samples.
	AudioServer.add_bus()
	var bus_index = AudioServer.bus_count - 1
	AudioServer.set_bus_name(bus_index, "HurtSoundTest")
	var capture = AudioEffectCapture.new()
	AudioServer.add_bus_effect(bus_index, capture)
	for direction in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		var scene = load("res://scenes/sewer.tscn").instantiate()
		root.add_child(scene)
		current_scene = scene
		await process_frame
		var player = scene.get_node("Player_Character")
		var enemy = scene.get_node("rat_enemies")
		var hitbox = enemy.get_node("AttackPivot/Hitbox")
		var sound = player.get_node("HurtSound")
		sound.bus = "HurtSoundTest"
		capture.clear_buffer()
		player.global_position = enemy.global_position + direction * 65.0
		var previous_hp = player.hitpoints
		var monitoring_frames = 0
		var sound_frames = 0
		var peak = 0.0
		var display = Label.new()
		var overlay = CanvasLayer.new()
		scene.add_child(overlay)
		overlay.add_child(display)
		display.position = Vector2(20, 20)
		display.add_theme_font_size_override("font_size", 24)
		display.add_theme_color_override("font_shadow_color", Color.BLACK)
		display.add_theme_constant_override("shadow_offset_x", 2)
		display.add_theme_constant_override("shadow_offset_y", 2)
		for frame in range(150):
			await physics_frame
			display.text = "Hurt sound test | Pip relative to enemy: %s\nHP: %d | Sound playing: %s" % [direction, player.hitpoints, sound.playing]
			if hitbox.monitoring:
				monitoring_frames += 1
			if sound.playing:
				sound_frames += 1
			for sample in capture.get_buffer(capture.get_frames_available()):
				peak = maxf(peak, maxf(absf(sample.x), absf(sample.y)))
		print("PROBE direction=", direction, " HP ", previous_hp, " -> ", player.hitpoints,
			" monitoring_frames=", monitoring_frames, " sound_frames=", sound_frames,
			" distance=", enemy.global_position.distance_to(player.global_position), " audio_peak=", peak)
		if player.hitpoints != previous_hp - 3 * enemy.enemyatkdmg or sound_frames == 0:
			push_error("Expected three damaging swings with sound in direction %s" % direction)
			failures += 1
		if DisplayServer.get_name() != "headless" and peak <= 0.0:
			push_error("Hurt sound produced no audio samples")
			failures += 1
		# Let the pending attack timer finish before removing this test scene.
		enemy.set_physics_process(false)
		await create_timer(1.1).timeout
		if hitbox.monitoring:
			push_error("Hitbox stayed active after the swing")
			failures += 1
		scene.queue_free()
		await process_frame
	AudioServer.remove_bus(bus_index)
	print("HURT SOUND TEST: ", "PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)
