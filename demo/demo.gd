extends Node
class_name Demo

var _has_initial_data_loaded = false

func _ready():
	
	TranslationsLoader.load_translations()
	# SaveData.loaded.connect(_on_savedata_loaded)
	# SaveData.progress_increased.connect(_on_progress_increased)

	# Initialize SaveData to defaults
	# SaveData.reset_data()
	# SaveData.max_progress = Constants.MAX_PROGRESS
	# Randomize seed
	randomize()
	
	if OS.has_feature("LoLApi"):
		_init_LoL()
		# SaveData.load_game delegated to LoLApi
	else:
		# await get_tree().process_frame
		# Wait a while to simulate delayed load
		# SaveData.load_game()
		# await get_tree().process_frame
		# Force save
		# SaveData.save_game()
		pass

func _on_savedata_loaded():
	# Usa el nuevo nombre más intuitivo:
	if _has_initial_data_loaded:
		return
	else:
		_has_initial_data_loaded = true # <--- NUEVO NOMBRE
	
	# Setting setting usign SaveData
	# TranslationsLoader.set_locale(SaveData.data.language)
	# settings.setup()
	
	# Start game here

#region LOL
func _init_LoL():
	_set_LoL_connection()
	LoLApi.send_init_message()

func _set_LoL_connection():
	LoLApi.init_message_received.connect(_on_LoL_init_message_received)
	LoLApi.awakening_settings_result_message_received.connect(_on_LoL_awakening_settings_result_message_received)
	LoLApi.start_message_received.connect(_on_LoL_start_message_received)
	LoLApi.questions_message_received.connect(_on_LoL_questions_message_received)
	LoLApi.translation_message_received.connect(_on_LoL_translation_message_received)
	LoLApi.load_state_message_received.connect(_on_LoL_load_state_message_received)
	LoLApi.save_state_result_message_received.connect(_on_LoL_save_state_result_message_received)
	LoLApi.pause_message_received.connect(_on_LoL_pause_message_received)
	LoLApi.unpause_message_received.connect(_on_LoL_unpause_message_received)

func _on_LoL_init_message_received(_payload: Dictionary):
	LoLApi.send_start_message()

func _on_LoL_awakening_settings_result_message_received(payload: Dictionary):
	# { "autoSpeak": false, "musicOn": false, "sfxOn": false }
	if payload.has("musicOn"):
		# SaveData.awakening_enabled_audio = payload.musicOn
		pass
	if payload.has("autoSpeak"):
		# SaveData.awakening_enabled_speaking = payload.autoSpeak
		pass

func _on_LoL_start_message_received(payload: Dictionary):
	# '{"languageCode":"en","awkAutoSpeak":false,"awkMusicOn":false,"awkSfxOn":false}'}
	if payload.has("awkMusicOn"):
		# SaveData.awakening_enabled_audio = payload.awkMusicOn
		pass
	if payload.has("awkAutoSpeak"):
		# SaveData.awakening_enabled_speaking = payload.awkAutoSpeak
		pass
	# SaveData.awakening_language = payload.languageCode
	
	LoLApi.send_saves_request_message()
	
func _on_LoL_questions_message_received(payload: Dictionary):
	print("Questions: " + str(payload))
	
func _on_LoL_translation_message_received(payload: Dictionary):
	TranslationsLoader.set_locale(payload.language)
	# SaveData.data.language = payload.language
	# settings.setup()
	
func _on_LoL_load_state_message_received(payload: Dictionary):
	if not payload.is_empty() and payload.has("data"):
		# SaveData.load_game(payload.data)
		if payload.has("currentProgress"):
			# Force initialization
			# SaveData.current_progress = payload.currentProgress
			pass
	else:
		# SaveData.load_game()
		pass
	await get_tree().process_frame
	# Force save in next frame
	# SaveData.save_game()
	pass
	
func _on_LoL_save_state_result_message_received(payload: Dictionary):
	if payload.result:
		print("Data save successfully!")
	
func _on_LoL_pause_message_received(_payload: Dictionary):
	get_tree().paused = true
	
func _on_LoL_unpause_message_received(_payload: Dictionary):
	get_tree().paused = false

#endregion
