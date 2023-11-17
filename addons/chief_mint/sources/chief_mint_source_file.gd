class_name ChiefMintSourceFile
extends ChiefMintSource
## Mint Source: File
## Chief Mint Source that uses a local saved file as the current state

var def_path
var save_path

var stored_data: ChiefMintSaveResource


func _init():
	def_path = ProjectSettings.get_setting(ChiefMintConstants.MINT_DEFINITION_SETTING)
	if def_path == null:
		def_path = ChiefMintConstants.MINT_DEFINITION_DEFAULT

	save_path = ProjectSettings.get_setting(ChiefMintConstants.MINT_SOURCE_LOCAL_PATH_SETTING)
	if save_path == null:
		save_path = ChiefMintConstants.MINT_SOURCE_LOCAL_PATH_DEFAULT
		_save()

	load_saved()


func get_source_name() -> String:
	return "file"


func load_defs() -> ChiefMintDefinitionsResource:
	if def_path == null or not ResourceLoader.exists(def_path):
		return ChiefMintDefinitionsResource.new()
	return load(def_path) as ChiefMintDefinitionsResource


func load_saved() -> ChiefMintSaveResource:
	if stored_data != null:
		return stored_data

	if save_path == null or not ResourceLoader.exists(save_path):
		stored_data = create_save_from_definitions(load_defs())
	else:
		stored_data = load(save_path) as ChiefMintSaveResource

	return stored_data


func clear_all_progress() -> bool:
	stored_data = create_save_from_definitions(load_defs())
	return _save()


static func create_save_from_definitions(
		defs: ChiefMintDefinitionsResource
	) -> ChiefMintSaveResource:
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
	#print("Trying to save {f}".format({'f': save_path}))
	var err = ResourceSaver.save(save_path, stored_data)
	if err == OK:
		#print("Saved {f}".format({'f': save_path}))
		return true

	printerr("Failed to save {f}!".format({"f": save_path}))
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
