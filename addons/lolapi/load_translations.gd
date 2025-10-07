class_name TranslationsLoader
extends Object
# Utility that loads translations json data and imports it in the game
# It is assumed the data is formatted as follows:
#{
#	"_meta": {
#		"maxChars": {
#			"welcome": 50
#		}
#	},
#	"en": {
#		"welcome": "Welcome"
#	}, 
#	"es": {
#		"welcome": "Bienvenido"
#	}
#}


const TRANSLATIONS_FILENAME = "res://translations.json"

# Will load the translations file from the root
# @returns: The loaded translations
static func load_translations() -> Dictionary:
	var translations_json = FileImportLib.file_to_string(TRANSLATIONS_FILENAME)
	var translations = ConversionsLib.json_to_dictionary(translations_json)
	process_translations(translations)
	TranslationServer.set_locale("en")
	return translations


# Process translation json data, ignoring language id's starting with "_"
# @param json_text: A string containing the json to process
static func process_translations(translations: Dictionary):
	for key in translations.keys():
		if not key.begins_with("_"):
			process_translation(key, translations[key])


# Process translation data from a dictionary. 
# The data is expected to be formatted like: {"GREET": "Hello!"}
# @param language_code: The code representing the language the translation is for
# @param translations: A dictionary containing the translations to process
static func process_translation(language_code: String, translations: Dictionary):
	var translation = Translation.new()
	translation.locale = language_code
	
	for key in translations.keys():
		translation.add_message(key, translations[key])
	
	TranslationServer.add_translation(translation)

static func set_locale(language_code: String):
	if language_code == "es":
		language_code = "es-ES"
	TranslationServer.set_locale(language_code)
	
static func format_float_localized(value: float, decimal_places: int = 2) -> String:
	var rounded := snappedf(value, pow(10, -decimal_places))
	
	if int(rounded) == rounded:
		return str(int(rounded))
	
	var formatted = String.num(rounded, decimal_places)
	var locale = TranslationServer.get_locale()

	if locale.begins_with("es"):
		formatted = formatted.replace(".", ",")

	return formatted
