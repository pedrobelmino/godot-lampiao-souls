extends Node

const MUSIC_PATH := "res://assets/audio/cathedral_amb.wav"
const SHOOT_PATH := "res://assets/audio/shoot.wav"

var _music: AudioStreamPlayer
var _shoot: AudioStreamPlayer


func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_music.name = &"Music"
	add_child(_music)
	var ms := load(MUSIC_PATH) as AudioStreamWAV
	if ms:
		ms.loop_mode = AudioStreamWAV.LOOP_FORWARD
		_music.stream = ms
		_music.volume_db = -20.0

	_shoot = AudioStreamPlayer.new()
	_shoot.name = &"Shoot"
	add_child(_shoot)
	var ss := load(SHOOT_PATH) as AudioStreamWAV
	if ss:
		_shoot.stream = ss
		_shoot.volume_db = -16.0


func start_music() -> void:
	if _music == null or _music.stream == null:
		return
	if _music.playing:
		return
	_music.play()


func play_shoot() -> void:
	if _shoot == null or _shoot.stream == null:
		return
	_shoot.play()
