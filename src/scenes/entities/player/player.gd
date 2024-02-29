class_name Player extends CharacterBody2D


@export_group("Movement")
#region Movement
@export var max_movement_speed: float = 200.0
@export var max_velocity: float = 800.0
@export var friction_force: float = 8.0
@export var friction_wieght: float = 0.5
var current_friction: float = 0.0
@export_subgroup("Pitch")
var current_pitch_input: float = 0.0
@export var pitch_speed: float = 6
@export var pitch_handling: float = 5
@export_subgroup("Acceleration + Deceleration")
var current_acceleration: float = 0.0
@export var acceleration_curve: Curve
@export var deceleration_factor: float = 4.0
#endregion
@export_group("Realm shifting")
#region Realm shifting
@export var shift_duration: float = 0.6
@export var shift_boost: float = 620.0
var shift_timer: Timer
@export var shift_reload_duration: float = 5.0
var shift_reload_timer: Timer
## If true player entered slow-mo state
var is_charging: bool = false
## Player velocity before entering the slow-mo state
#var frozen_velocity: Vector2 = Vector2.ZERO
#endregion


func _ready() -> void:
	assert(is_instance_valid(acceleration_curve), "Player MUST have an acceleration curve")
	
	shift_timer = Timer.new()
	shift_timer.one_shot = true
	shift_timer.autostart = false
	shift_timer.wait_time = shift_duration
	shift_timer.timeout.connect(_on_shift_timer)
	add_child(shift_timer)
	
	shift_reload_timer = Timer.new()
	shift_reload_timer.one_shot = true
	shift_reload_timer.autostart = false
	shift_reload_timer.wait_time = shift_duration + shift_reload_duration
	shift_reload_timer.timeout.connect(_on_shift_reload_timer)
	add_child(shift_reload_timer)


func _physics_process(delta: float) -> void:
	var dir: Vector2 = Vector2(
		Input.get_action_strength("player_right") - Input.get_action_strength("player_left"),
		Input.get_action_strength("player_down") - Input.get_action_strength("player_up")
	).normalized()
	var dir_rotated: Vector2 = dir.rotated(rotation)
	
	#region Rotation
	current_pitch_input = lerpf(
		current_pitch_input, dir.x,
		pitch_handling * delta
	)
	rotation += pitch_speed * current_pitch_input * delta # * 0.0166
	
	var _rot_cos: float = cos(rotation)
	var _rot_sin: float = sin(rotation)
	#endregion
	
	#region Slow-mo --> Realm shifting
	if Input.is_action_just_pressed("player_shift_realm"):
		if shift_reload_timer.is_stopped() and not is_charging:
			is_charging = true
	elif is_charging:
		if Input.is_action_just_released("player_shift_realm"):
			is_charging = false
			velocity.x = shift_boost *  _rot_sin
			velocity.y = shift_boost * -_rot_cos
			shift_timer.start()
			shift_reload_timer.start()
			Realm.shift_to_opposite()
	#endregion
	else:
		#region Acceleration/Deceleration
		var _acceleration: float = snappedf(current_acceleration, 0.01)
		if dir.y < 0:
			velocity += 10.0 * dir_rotated * acceleration_curve.sample_baked(_acceleration)
			current_acceleration += delta
		else:
			velocity = velocity.move_toward(Vector2.ZERO, deceleration_factor * (1 + dir.y))
			current_acceleration = 0.0
		
		current_acceleration = clampf(current_acceleration, 0.0, 1.0)
		#endregion
		#region Friction
		velocity = velocity.lerp(Vector2.ZERO, 1.5 * delta)
		#endregion
	
	if shift_timer.is_stopped():
		velocity.x = clampf(velocity.x, -max_movement_speed, max_movement_speed)
		velocity.y = clampf(velocity.y, -max_movement_speed, max_movement_speed)
	
	move_and_slide()


#region Realm shifting timers
func _on_shift_timer() -> void:
	pass

func _on_shift_reload_timer() -> void:
	pass
#endregion
