class_name GameRoot extends Node

#region Visuals
	#region Shaders
@onready var shader_main_viewport: ShaderMaterial = %viewport_no_crt.material as ShaderMaterial
@onready var shader_crt: ShaderMaterial = %crt_overlay.material as ShaderMaterial
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
	
