class_name FileImportLib
extends Library
# Library for importing files
# Provides functions for converting files to a usable data format


enum File_Types {JSON}


func get_class() -> String: return "FileImportLib"


# Converts file data to a Dictionary containing sub-dictionaries.
# @param file_path: The path to the file with data to convert
# @param file_type: The type of file to convert
# @returns: A dictionary containing the data from the file
static func file_to_dictionary(file_path: String, file_type: int) -> Dictionary:
	assert(file_type in File_Types.values(), "The file type is expected to be a File_Types enum value")
	
	var file_content = file_to_string(file_path)
	match file_type:
		File_Types.JSON:
			return ConversionsLib.json_to_dictionary(file_content)
		
	printerr("File: '{0}' could not be converted because it has an unknown type".format([file_path]))
	return {}


# Converts file data to an array containing dictionaries.
# @param file_path: The path to the file with data to convert
# @param file_type: The type of file to convert
# @returns: An array containing the data from the file
static func file_to_array(file_path: String, file_type: int) -> Array:
	assert(file_type in File_Types.values(), "The file type is expected to be a File_Types enum value")
	
	var file_content = file_to_string(file_path)
	match file_type:
		File_Types.JSON:
			return ConversionsLib.json_to_array(file_content)
		
	printerr("File: '{0}' could not be converted because it has an unknown type".format([file_path]))
	return []


# Extracts json file data and saves it to a String.
# @param json_file: The json file with data to convert
# @returns: A Dictionary containing a sub-dictionaries for each element
static func file_to_string(file_path: String) -> String:
	var file_text = ""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		printerr("Error while opening file: " + 
			StringLib.quotify(file_path)
		)
	else:
		file_text = file.get_as_text()
		file.close()
	
	return file_text
