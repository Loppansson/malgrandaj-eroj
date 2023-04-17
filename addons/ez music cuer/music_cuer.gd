class_name StaticMusicCuer
extends Node

## Cues music on regular intervals.
##
## Cues a [MusicPlayer] to play the first entry in it's 
## [code]_music_sources[/code] [Dictionary] on regular intervals. If the 
## [code]music_player[/code] variable is empty at [method _ready], the 
## [StaticMusicCuer] assigns it's parent to the [code]music_player[/code] 
## variable.[br]
## [br]
## [b]Dependencies:[/b] EZ Sfz and Music, by ghoulbroth (from the AssetLib)

## The [MusicPlayer] used. If empty at [method _ready], [code]self[/code]'s 
## parent is used.
@export var music_player:  MusicPlayer
## The time in secounds between [StaticMusicCuer] cues music.
@export var cue_interval := 150 as int
## If true, music starts playing after [member start_offset] secounds. If false
## [StaticMusicCuer] starts only when the [method start] is called.
@export var autostart := true
## The time in secounds before music plays for the first time.
@export var start_offset := 0 as float
## The [Timer] used to count down between cues.
var _interval_timer := Timer.new()


func _ready():
	if autostart:
		start()

## Sets up the [member _interval_timer] and [member music_player].
func start():
	## Waits in acordance with [member start_offset].
	await get_tree().create_timer(start_offset).timeout
	_set_up_interval_timer()
	_set_up_music_player()

## Connect the [member _interval_timer]'s [signal Timer.timeout] signal to 
## [method _on_Music_interval_timer_timeout], change [member _interval_timer]'s 
## name to [code]"MusicIntervalTimer"[/code], and add it as [member self]'s 
## child.
func _set_up_interval_timer() -> void:
	_interval_timer.connect(
			"timeout", 
			Callable(self, "_on_MusicIntervalTimer_timeout")
	)
	_interval_timer.name = "MusicIntervalTimer"
	add_child(_interval_timer)


## Sets [member music_player] to [member self]'s parent, if 
## [member music_player] is empty. Waits for [member music_player] to load it's
## music sources.
func _set_up_music_player() -> void:
	if not music_player:
		assert(
				get_parent() as MusicPlayer, 
				"music_player is empty and StaticMusicCuer's parent is not " +
				"of type MusicPlayer"
		)
		music_player = get_parent()
	
	while music_player._music_sources.is_empty():
		await get_tree().create_timer(0.1).timeout
	_give_cue()


## Plays the song in [code]music_player[/code]'s first music source and starts 
## the [code]_interval_timer[/code].
func _give_cue():
	# Plays the music_player's first music source.
	music_player.play(music_player._music_sources.keys()[0])
	
	_interval_timer.start(cue_interval)

## Plays music when the _interval_timer runs out and restarts the _interval_timer.
func _on_MusicIntervalTimer_timeout() -> void:
	_give_cue()
