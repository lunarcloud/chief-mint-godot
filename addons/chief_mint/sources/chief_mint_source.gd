extends Node
class_name ChiefMintSource


func get_source_name() -> String:
	return "none"


func load_defs() -> ChiefMintDefinitionsResource:
	return ChiefMintDefinitionsResource.new()


func load_saved() -> ChiefMintSaveResource:
	return ChiefMintSaveResource.new()


func clear_all_progress() -> bool:
	return false


func increment_progress(name: String) -> ChiefMintResource:
	return ChiefMintResource.new()


func set_progress(name: String, value) -> ChiefMintResource:
	return ChiefMintResource.new()


func is_complete(name: String) -> bool:
	return false


func get_progress(name: String) -> ChiefMintProgress:
	return ChiefMintProgress.new()

