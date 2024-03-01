extends Node

@onready var pre_shift_sfx: AudioStreamPlayer = %pre_shift_sfx
## Effect system must have access to main shaders, audio and etc.
var game_root: GameRoot
var music_bus_index: int = 0

func init(target: GameRoot) -> void:
	game_root = target
	music_bus_index = AudioServer.get_bus_index("Music")
	print(music_bus_index)


## Freeze state
func enter_pre_shift() -> void:
	const duration: float = 1.0
	var context: Tw.TwContext = Tw.create_context(
		Tween.EASE_IN_OUT, Tween.TRANS_CIRC
	).tween_shader(
		game_root.shader_grid_bg,
		{"zoom": 18.0}, duration
	).tween_shader(
		game_root.shader_crt_game,
		{"offset_r": 2.5, "offset_b": 2.5}, duration
	).tween(
		Engine, {"time_scale": 0.2}, duration
	).tween_audio_effect(
		music_bus_index, 0, {"cutoff_hz": 2000}, duration
	).tween_audio_effect(
		music_bus_index, 1, {"cutoff_hz": 2000}, duration
	)
	pre_shift_sfx.play(0.5)
	context.play_bg()


func shift_realm(to: Realm.State) -> void:
	Engine.time_scale = 1.0
