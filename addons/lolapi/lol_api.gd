extends Node

# Wrapper class for communicating with the LoL API through JavaScript.
# This class must be autoloaded so it can initialize connections once and be used globally.

signal awakening_settings_result_message_received(payload)
signal init_message_received(payload)
signal start_message_received(payload)
signal questions_message_received(payload)
signal translation_message_received(payload)
signal load_state_message_received(payload)
signal save_state_result_message_received(payload)
signal pause_message_received(payload)
signal unpause_message_received(payload)

const INCOMING_MESSAGE_NAMES = {
	"awakeningSettingsResult": "awakening_settings_result_message_received",
	"init": "init_message_received",
	"start": "start_message_received",
	"questions": "questions_message_received",
	"language": "translation_message_received",
	"loadState": "load_state_message_received",
	"pause": "pause_message_received",
	"resume": "unpause_message_received",
	"saveStateResult": "save_state_result_message_received",
}
const OUTGOING_MESSAGE_NAMES = {
	"INIT": "init",
	"READY": "gameIsReady",
	"TTS": "speakText",
	"REQ_SAVES": "loadState",
	"SAVE": "saveState",
	"PROGRESS": "progress",
	"COMPLETE": "complete",
}
const OUTGOING_MESSAGE_PAYLOADS = {
	"INIT": """{ 
		"aspectRatio": "{aspect_ratio}",
		"resolution": "{resolution}",
		"sdkVersion": "{sdk_version}"
	}""",
	"READY": """{ 
		"aspectRatio": "{aspect_ratio}",
		"resolution": "{resolution}"
	}""",
	"TTS": """{ 
		"key": "{translation_text_key}"
	}""",
	"REQ_SAVES": "\"*\"",
	"SAVE": """{
		"currentProgress": {current_progress},
		"maximumProgress": {maximum_progress},
		"data": {data}
	}""",
	"PROGRESS": """{ 
		"currentProgress": {current_progress},
		"maximumProgress": {maximum_progress}
	}""",
	"PROGRESS_SCORE": """{ 
		"currentProgress": {current_progress},
		"maximumProgress": {maximum_progress},
		"score": {score}
	}""",
}

var _receive_message_callback = JavaScriptBridge.create_callback(receive_message)

func _init():
	if OS.has_feature("LoLApi"):
		JavaScriptBridge.get_interface("window").call("addEventListener", "message", _receive_message_callback)

func receive_message(msg):
	var json_data = JavaScriptBridge.get_interface("JSON").call("stringify", msg[0].data)
	var message_data = JSON.parse_string(json_data)
	
	if typeof(message_data) != TYPE_DICTIONARY:
		printerr("[LoLApi->Game] Receiving message: Invalid message format")
		return
	
	var message_name = message_data.get("messageName", "")
	var payload = null
	
	if message_data.has("payload") and typeof(message_data["payload"]) == TYPE_STRING:
		payload = JSON.parse_string(message_data["payload"])
	
	if (message_name != null):
		if INCOMING_MESSAGE_NAMES.has(message_name):
			if payload != null:
				print("[LoLApi->Game] Receiving message: {0} with payload: {1}".format([
					message_name, payload
				]))
				emit_signal(INCOMING_MESSAGE_NAMES[message_name], payload)
			else:
				print("[LoLApi->Game] Receiving message: {0} without payload".format([
					message_name
				]))
				# Send with empty Dictionary
				emit_signal(INCOMING_MESSAGE_NAMES[message_name], {})
		else:
			printerr("[LoLApi->Game] Receiving message: Unhandled message name: " + str(message_data))
	else:
		printerr("[LoLApi->Game] Receiving message: Unhandled message: " + str(message_data))

func send_init_message():
	# SPECIAL CASE: Based on the Unity SDK (LoLWebGL.jslib), I noticed that it also sends an init
	# message from the game to the parent, which might be required to “unlock” the response from
	# the platform in some environments.
	var payload = OUTGOING_MESSAGE_PAYLOADS.INIT.format({
		"aspect_ratio": "16:9",
		"resolution": ConversionsLib.vector2_to_string(DisplayServer.window_get_size()),
		"sdk_version": "5.4"	# == lol_spec.json
	})
	_send_message("INIT", payload)

func send_ready_message():
	var payload = OUTGOING_MESSAGE_PAYLOADS.READY.format({
		"aspect_ratio": "16:9",
		"resolution": ConversionsLib.vector2_to_string(DisplayServer.window_get_size()),
	})
	_send_message("READY", payload)

func send_tts_message(text_key: String):
	var payload = OUTGOING_MESSAGE_PAYLOADS.TTS.format({
		"translation_text_key": text_key
	})
	_send_message("TTS", payload)

func send_saves_request_message():
	_send_message("REQ_SAVES", OUTGOING_MESSAGE_PAYLOADS.REQ_SAVES)

func send_save_state_message(current_progress: int, maximum_progress: int, data: Dictionary):
	var data_json = JSON.stringify(data)
	var payload = OUTGOING_MESSAGE_PAYLOADS.SAVE.format({
		"current_progress": current_progress,
		"maximum_progress": maximum_progress,
		"data": data_json
	})
	_send_message("SAVE", payload)

func send_progress_message(current_progress: int, maximum_progress: int):
	var payload = OUTGOING_MESSAGE_PAYLOADS.PROGRESS.format({
		"current_progress": current_progress,
		"maximum_progress": maximum_progress
	})
	_send_message("PROGRESS", payload)

func send_progress_and_score_message(current_progress: int, maximum_progress: int, score: int):
	var payload = OUTGOING_MESSAGE_PAYLOADS.PROGRESS_SCORE.format({
		"current_progress": current_progress,
		"maximum_progress": maximum_progress,
		"score": score
	})
	_send_message("PROGRESS", payload)

func send_complete_message():
	_send_message("COMPLETE")

func _send_message(message_name: String, payload: String = "{}"):
	if OS.has_feature("LoLApi"):
		
		if not OUTGOING_MESSAGE_NAMES.has(message_name):
			push_error("[Game->LoLApi] Sending message: Unhandled message name: " + message_name)
			return
		
		var message = OUTGOING_MESSAGE_NAMES[message_name]
		var command = """
			parent.postMessage({
				message: "{message}",
				payload: JSON.stringify({payload})
			}, '*');
		""".format({ "message": message, "payload": payload })
		
		JavaScriptBridge.eval(command)
		
		print("[Game->LoLApi] Sending message: {0} with payload: {1}".format([
			message, payload
		]))
