extends Node

@onready var pre_shift_sfx: AudioStreamPlayer = %pre_shift_sfx
@onready var shift_sfx: AudioStreamPlayer = %shift_sfx
## Effect system must have access to main shaders, audio and etc.
var game_root: GameRoot
var music_bus_index: int = 0

func init(target: GameRoot) -> void:
	game_root = target
	music_bus_index = AudioServer.get_bus_index("Music")


## Freeze state
func enter_pre_shift() -> void:
	const duration: float = 0.5
	var context: Tw.TwContext = Tw.create_context(
		Tween.EASE_IN_OUT, Tween.TRANS_CIRC
	).tween_shader(
		game_root.shader_grid_bg,
		{"zoom": 18.0}, duration
	).tween_shader(
		game_root.shader_crt,
		{"game_offset_r": 2.5, "game_offset_b": 2.5}, duration
	).tween(
		Engine, {"time_scale": 0.2}, duration
	).tween_audio_effect(
		music_bus_index, 0, {"cutoff_hz": 2000}, duration
	).tween_audio_effect(
		music_bus_index, 1, {"cutoff_hz": 2000}, duration
	)
	context.play_bg()
	pre_shift_sfx.play(0.5)


func shift_realm(to: Realm.State) -> void:
	const duration: float = 1.0
	
	#var center_uv: Vector2 = game_root.player.get_uv()
	#Tw._set_shader_param(center_uv, "center", game_root.shader_main_viewport)
	#Tw._set_shader_param(center_uv, "center", game_root.shader_crt)
	
	var context: Tw.TwContext = Tw.create_context(
		Tween.EASE_IN_OUT, Tween.TRANS_CIRC
	).tween_shader(
		game_root.shader_grid_bg,
		{"zoom": 30.0}, duration
	).tween_shader(
		game_root.shader_crt,
		{"game_offset_r": 0.0, "game_offset_b": 0.0}, duration
	).tween_shader(
		game_root.shader_main_viewport, 
		{"size": 2.4}, duration * 0.5
	).tween_shader(
		game_root.shader_crt, 
		{"size": 2.4}, duration * 0.5
	).tween_audio_effect(
		music_bus_index, 0, {"cutoff_hz": 20500}, duration
	).tween_audio_effect(
		music_bus_index, 1, {"cutoff_hz": 20500}, duration
	).tween(
		Engine, {"time_scale": 1.0}, duration * 0.5
	)
	pre_shift_sfx.stop()
	shift_sfx.play()
	context.play_bg()
