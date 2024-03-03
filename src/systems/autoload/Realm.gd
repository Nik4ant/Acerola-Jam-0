extends Node

enum State {
	Game,
	Dev
}
var state: State = State.Game
signal realm_shifted(new_state: State)


func shift_to(new: State) -> void:
	realm_shifted.emit(new)

func shift_to_opposite() -> void:
	match state:
		State.Game:
			state = State.Dev
		State.Dev:
			state = State.Game
	
	EffectsSystem.shift_realm(state)
	realm_shifted.emit(state)
