extends Node

const MUSIC_PATH := "res://assets/audio/cathedral_amb.wav"
const SHOOT_PATH := "res://assets/audio/shoot.wav"

var _music: AudioStreamPlayer
var _shoot: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music = AudioStreamPlayer.new()
	_music.name = &"Music"
	_music.bus = &"Master"
	add_child(_music)
	var ms = load(MUSIC_PATH)
	if ms is AudioStreamWAV:
		var wav := (ms as AudioStreamWAV).duplicate() as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		_music.stream = wav
		_music.volume_db = -14.0

	_shoot = AudioStreamPlayer.new()
	_shoot.name = &"Shoot"
	_shoot.bus = &"Master"
	add_child(_shoot)
	var ss = load(SHOOT_PATH)
	if ss is AudioStreamWAV:
		_shoot.stream = ss as AudioStreamWAV
		_shoot.volume_db = -16.0


func start_music() -> void:
	if _music == null or _music.stream == null:
		return
	if _music.playing:
		return
	_music.play()


func stop_music() -> void:
	if _music == null:
		return
	if _music.playing:
		_music.stop()


func play_shoot() -> void:
	if _shoot == null or _shoot.stream == null:
		return
	_shoot.play()
