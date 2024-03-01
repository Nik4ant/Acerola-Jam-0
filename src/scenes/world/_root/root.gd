class_name GameRoot extends Node

#region Visuals
	#region Shaders
@onready var dev_realm_shaders: Control = %dev_realm_shaders
@onready var game_realm_shaders: Control = %game_realm_shaders

@onready var shader_crt_dev: ShaderMaterial = %shader_crt_dev.material as ShaderMaterial
@onready var shader_sobel_dev: ShaderMaterial = %shader_sobel_dev.material as ShaderMaterial

@onready var shader_glow_game: ShaderMaterial = %shader_glow_game.material as ShaderMaterial
@onready var shader_crt_game: ShaderMaterial = %shader_crt_game.material as ShaderMaterial

@onready var shader_grid_bg: ShaderMaterial = (%shader_grid).material as ShaderMaterial
	#endregion
	#region Canvas groups
@onready var red_stripes_group: CanvasGroup = %red_stripes
@onready var green_stripes_group: CanvasGroup = %green_stripes
@onready var blue_stripes_group: CanvasGroup = %blue_stripes
	#endregion
#endregion

@onready var bg_music: AudioStreamPlayer = %bg_music

@onready var player: Player = %player
@onready var camera: Camera2D = %camera


func _ready() -> void:
	EffectsSystem.init(self)
	dev_realm_shaders.visible = false
	game_realm_shaders.visible = true
