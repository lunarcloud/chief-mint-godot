class_name ChiefMintSingleton
extends Node
## Chief Mint Singleton
## The singleton which manages and is used to facilitate achievement usage in-game.

signal loaded_from_source
signal progress_changed(ChiefMintResource)

var state: ChiefMintSaveResource
var source: ChiefMintSource


func _ready():
	var source_path = ProjectSettings.get_setting(ChiefMintConstants.MINT_SOURCE_SETTING)
	if source_path == null or not ResourceLoader.exists(source_path):
		source = load(ChiefMintConstants.MINT_SOURCE_DEFAULT).new()
	else:
		source = load(source_path).new()

	if source == null:
		push_error("ChiefMint: Failed to initialize source. Achievement system will not function.")
		return
	
	# Connect to completion achievement signal
	source.completion_achievement_unlocked.connect(_on_completion_achievement_unlocked)
	
	load_from_source()


## Create a Mint Resource from Definition
func init_resource_from_def(def: ChiefMintDefinitionResource) -> ChiefMintResource:
	var res := ChiefMintResource.new()
	res.definition = def
	res.progress = ChiefMintProgress.new()
	return res


## Load the Mints from the source
func load_from_source() -> void:
	if source == null:
		push_error("ChiefMint: Cannot load from source - source is null")
		return
	
	state = source.load_saved()
	loaded_from_source.emit()


## Reset progress (optional for source to implement)
func clear_all_progress() -> bool:
	if source == null:
		push_error("ChiefMint: Cannot clear progress - source is null")
		return false
	return source.clear_all_progress()


## Get the name of the source in use
func get_source_name() -> String:
	if source == null:
		push_error("ChiefMint: Cannot get source name - source is null")
		return "error"
	return source.get_source_name()


## Increment the progress of a mint
func increment_progress(name: String) -> void:
	if source == null:
		push_error("ChiefMint: Cannot increment progress - source is null")
		return
	
	if !is_complete(name):
		var progress = source.get_progress(name)
		if progress == null:
			push_error("ChiefMint: Cannot increment progress - achievement '%s' not found" % name)
			return
		
		var old_progress: int = progress.current
		var resource = source.increment_progress(name)
		var changed = old_progress != resource.progress.current
		if changed:
			progress_changed.emit(resource)


## Force the progress of a mint to a specific value (optional for source to implement)
func set_progress(name: String, value) -> void:
	if source == null:
		push_error("ChiefMint: Cannot set progress - source is null")
		return
	
	var progress = source.get_progress(name)
	if progress == null:
		push_error("ChiefMint: Cannot set progress - achievement '%s' not found" % name)
		return
	
	var old_progress: int = progress.current
	var resource = source.set_progress(name, value)
	var changed = old_progress != resource.progress.current
	if changed:
		progress_changed.emit(resource)


## Get whether the mint is considered achieved
func is_complete(name: String) -> bool:
	if source == null:
		push_error("ChiefMint: Cannot check completion - source is null")
		return false
	return source.is_complete(name)


## Get the progress towards the completion of a mint
func get_progress(name: String) -> ChiefMintProgress:
	if source == null:
		push_error("ChiefMint: Cannot get progress - source is null")
		return ChiefMintProgress.new()
	return source.get_progress(name)


## Handle completion achievement unlocked signal from source
func _on_completion_achievement_unlocked(completion_mint: ChiefMintResource) -> void:
	progress_changed.emit(completion_mint)
