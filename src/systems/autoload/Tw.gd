extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

#region TwContext
class TwContext:
	signal finished
	
	var _tween: Tween
	## Stores values of all properties before tweening
	## { key: Variant|ShaderMaterial, value: Dictionary[String, Variant] }
	var initial_properties: Dictionary = {}
	
	func tween(target: Variant, params: Dictionary, duration: float) -> TwContext:
		initial_properties[target] = {}
		
		for property: String in params.keys():
			var from: Variant = target.get(property)
			initial_properties[target][property] = from
			
			self._tween.tween_property(
				target,
				property,
				params[property],
				duration
			)
		
		return self
	
	func tween_shader(shader: ShaderMaterial, params: Dictionary, duration: float) -> TwContext:
		initial_properties[shader] = {}
		
		for property: String in params.keys():
			var from: Variant = shader.get_shader_parameter(property)
			assert(from != null, "Can't tween `" + property + "`, property doesn't exist!")
			initial_properties[shader][property] = from
			
			self._tween.tween_method(
				Tw._set_shader_param.bind(property, shader),
				from,
				params[property],
				duration
			)
		
		return self
	
	func tween_audio_effect(bus_idx: int, effect_idx: int, params: Dictionary, duration: float) -> TwContext:
		var effect: AudioEffect = AudioServer.get_bus_effect(bus_idx, effect_idx)
		return self.tween(effect, params, duration)
	
	## Resets values of all affected Nodes/Resources to values before tweening
	func reset() -> TwContext:
		for target: Variant in initial_properties.keys():
			if target is ShaderMaterial:
				for prop_name: String in initial_properties[target]:
					target.set_shader_parameter(
						prop_name, initial_properties[target][prop_name]
					)
			elif is_instance_valid(target):
				for prop_name: String in initial_properties[target]:
					target.set(prop_name, initial_properties[target][prop_name])
			else:
				push_error("ERROR! Can't reset properties for `", target, "`")
				breakpoint
		
		return self
	
	func chain() -> TwContext:
		self._tween = self._tween.chain()
		return self
	
	## Plays the tween in the background (doesn't wait for it to finish)
	func play_bg() -> TwContext:
		self._tween.finished.connect(
			func() -> void:
				finished.emit()
		, CONNECT_ONE_SHOT)
		
		self._tween.play()
		return self
	
	## Plays the tween and waits for it to finish
	func play_wait() -> TwContext:
		self._tween.play()
		await self._tween.finished
		return self
	
	func stop() -> TwContext:
		self._tween.stop()
		return self
#endregion

#region Other
static func _set_shader_param(new_value: Variant, param_name: String, shader: ShaderMaterial) -> void:
	shader.set_shader_parameter(param_name, new_value)

func create_context(easing: Tween.EaseType = Tween.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TRANS_LINEAR, parallel: bool = true) -> TwContext:
	var context: TwContext = TwContext.new()
	var _tween: Tween = create_tween()
	_tween.set_ease(easing)
	_tween.set_trans(trans)
	_tween.set_parallel(parallel)
	context._tween = _tween
	
	return context
#endregion

#region Functions
func tween(target: Variant, params: Dictionary, duration: float,
		easing: Tween.EaseType = Tween.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TRANS_LINEAR, parallel: bool = true) -> TwContext:
	var ctx: TwContext = create_context(easing, trans, parallel)
	return ctx.tween(target, params, duration)

func tween_shader(shader: ShaderMaterial, params: Dictionary, duration: float,
		easing: Tween.EaseType = Tween.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TRANS_LINEAR, parallel: bool = true) -> TwContext:
	return create_context(easing, trans, parallel).tween_shader(shader, params, duration)

func tween_audio_effect(bus_idx: int, effect_idx: int, params: Dictionary, duration: float,
		easing: Tween.EaseType = Tween.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TRANS_LINEAR, parallel: bool = true) -> TwContext:
	var effect: AudioEffect = AudioServer.get_bus_effect(bus_idx, effect_idx)
	return tween(effect, params, duration, easing, trans, parallel)
#endregion
