@tool
extends EditorPlugin

const AUTOLOAD_NAME = "LoLApi"
const SCRIPT_PATH = "res://addons/lolapi/lol_api.gd"

func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, SCRIPT_PATH)


func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
