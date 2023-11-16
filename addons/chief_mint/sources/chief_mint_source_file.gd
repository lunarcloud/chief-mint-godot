extends ChiefMintSource
class_name ChiefMintSourceFile


var defPath
var savePath

var stored_data : ChiefMintSaveResource

func _init():
	defPath = ProjectSettings.get_setting(ChiefMintConstants.MINT_DEFINITION_SETTING)
	if defPath == null:
		defPath = ChiefMintConstants.MINT_DEFINITION_DEFAULT
	
	savePath = ProjectSettings.get_setting(ChiefMintConstants.MINT_SOURCE_LOCAL_PATH_SETTING)
	if savePath == null:
		savePath = ChiefMintConstants.MINT_SOURCE_LOCAL_PATH_DEFAULT
	
	load_saved()


func get_source_name() -> String:
	return "file"


func load_defs() -> ChiefMintDefinitionsResource:
	if defPath == null or not ResourceLoader.exists(defPath):
		return ChiefMintDefinitionsResource.new()
	else:
		return load(defPath) as ChiefMintDefinitionsResource


func load_saved() -> ChiefMintSaveResource:
	if stored_data != null:
		return stored_data

	if savePath == null or not ResourceLoader.exists(savePath):
		stored_data = save_from_definitions(load_defs())
	else:
		stored_data = load(savePath) as ChiefMintSaveResource
	
	return stored_data


static func save_from_definitions(defs: ChiefMintDefinitionsResource) -> ChiefMintSaveResource:
	var data = ChiefMintSaveResource.new()
	for def in defs.definitions:
		var mint = ChiefMintResource.new()
		mint.definition = def
		mint.progress = ChiefMintProgress.new()
		mint.progress.maximum = mint.definition.maximum_progress
		mint.progress.current = 0
		data.mints.append(mint)
	return data


func increment_progress(name: String) -> ChiefMintResource:
	for mint in stored_data.mints:
		if mint.definition.name == name:
			mint.progress.current += 1
			return mint
	return null


func set_progress(name: String, value) -> ChiefMintResource:
	for mint in stored_data.mints:
		if mint.definition.name == name:
			mint.progress.current = value
			return mint
	return null


func get_progress(name: String) -> ChiefMintProgress:
	for mint in stored_data.mints:
		if mint.definition.name == name:
			return mint.progress
	return null

