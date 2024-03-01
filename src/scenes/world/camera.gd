extends Camera2D

@export var target: Player
@export var offset_distance: float = 75.0
@export var camera_speed: float = 0.1

func _ready() -> void:
	assert(is_instance_valid(target), "Camera MUST have a target")

func _physics_process(_delta: float) -> void:
	var normalized = target.velocity.normalized()
	offset.x = lerpf(offset.x, normalized.x * offset_distance, camera_speed)
	offset.y = lerpf(offset.y, normalized.y * offset_distance, camera_speed)
	
	global_position.x = lerpf(global_position.x, target.global_position.x, camera_speed)
	global_position.y = lerpf(global_position.y, target.global_position.y, camera_speed)
