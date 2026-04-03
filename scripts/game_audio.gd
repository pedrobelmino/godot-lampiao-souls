extends Node

const SHOOT_PATH := "res://assets/audio/shoot.wav"

var _shoot: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_shoot = AudioStreamPlayer.new()
	_shoot.name = &"Shoot"
	_shoot.bus = &"Master"
	add_child(_shoot)
	var ss = load(SHOOT_PATH)
	if ss is AudioStreamWAV:
		_shoot.stream = ss as AudioStreamWAV
		_shoot.volume_db = -16.0


func play_shoot() -> void:
	if _shoot == null or _shoot.stream == null:
		return
	_shoot.play()
