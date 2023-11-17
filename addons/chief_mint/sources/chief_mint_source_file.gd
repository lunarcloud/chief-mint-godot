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
		_save()
	
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
		stored_data = create_save_from_definitions(load_defs())
	else:
		stored_data = load(savePath) as ChiefMintSaveResource
	
	return stored_data


func clear_all_progress() -> bool:
	stored_data = create_save_from_definitions(load_defs())
	return _save()


static func create_save_from_definitions(defs: ChiefMintDefinitionsResource) -> ChiefMintSaveResource:
	var data = ChiefMintSaveResource.new()
	for def in defs.definitions:
		var mint = ChiefMintResource.new()
		mint.definition = def
		mint.progress = ChiefMintProgress.new()
		mint.progress.maximum = mint.definition.maximum_progress
		mint.progress.current = 0
		data.mints.append(mint)
	return data


func _save() -> bool:
	#print("Trying to save {f}".format({'f': savePath}))
	var err = ResourceSaver.save(savePath, stored_data)
	if err == OK:
		#print("Saved {f}".format({'f': savePath}))
		return true
	else:
		printerr("Failed to save {f}!".format({'f': savePath}))
		return false


func increment_progress(name: String) -> ChiefMintResource:
	for mint in stored_data.mints:
		if mint.definition == null:
			pass
		elif mint.definition.name == name:
			mint.progress.current += 1
			_save()
			return mint
	return null


func set_progress(name: String, value) -> ChiefMintResource:
	for mint in stored_data.mints:
		if mint.definition.name == name:
			mint.progress.current = value
			_save()
			return mint
	return null


func is_complete(name: String) -> bool:
	for mint in stored_data.mints:
		if mint.definition.name == name:
			return mint.progress.is_complete()
	return false


func get_progress(name: String) -> ChiefMintProgress:
	for mint in stored_data.mints:
		if mint.definition.name == name:
			return mint.progress
	return null

