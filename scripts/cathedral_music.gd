extends Node
## Música ambiente da catedral (só instanciada nas fases 2 e 3). Para com a troca de cena.

@onready var _player: AudioStreamPlayer = $StreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var s := _player.stream
	if s is AudioStreamOggVorbis:
		var ogg := (s as AudioStreamOggVorbis).duplicate() as AudioStreamOggVorbis
		ogg.loop = true
		_player.stream = ogg
	_player.volume_db = -9.0
	call_deferred(&"_start")


func _start() -> void:
	if _player.stream == null:
		return
	_player.play()
