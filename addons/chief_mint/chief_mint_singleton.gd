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

	load_from_source()


## Create a Mint Resource from Definition
func init_resource_from_def(def: ChiefMintDefinitionResource) -> ChiefMintResource:
	var res := ChiefMintResource.new()
	res.definition = def
	res.progress = ChiefMintProgress.new()
	return res


## Load the Mints from the source
func load_from_source() -> void:
	if source != null:
		state = source.load_saved()
		loaded_from_source.emit()


## Reset progress (optional for source to implement)
func clear_all_progress() -> bool:
	return false if source == null else source.clear_all_progress()


## Get the name of the source in use
func get_source_name() -> String:
	return "error" if source == null else source.get_source_name()


## Increment the progress of a mint
func increment_progress(name: String) -> void:
	if source != null and !is_complete(name):
		var old_progress: int = source.get_progress(name).current

		# Check if completion achievement is incomplete before the increment
		var completion_mint = _get_completion_mint()
		var completion_was_incomplete = false
		if completion_mint != null:
			completion_was_incomplete = not completion_mint.progress.is_complete()

		var resource = source.increment_progress(name)
		var changed = old_progress != resource.progress.current
		if changed:
			progress_changed.emit(resource)

			# Check if completion achievement just became complete
			if completion_was_incomplete and completion_mint != null:
				if completion_mint.progress.is_complete():
					progress_changed.emit(completion_mint)


## Force the progress of a mint to a specific value (optional for source to implement)
func set_progress(name: String, value) -> void:
	if source != null:
		var old_progress: int = source.get_progress(name).current
		var resource = source.set_progress(name, value)
		var changed = old_progress != resource.progress.current
		if changed:
			progress_changed.emit(resource)


## Get whether the mint is considered achieved
func is_complete(name: String) -> bool:
	return false if source == null else source.is_complete(name)


## Get the progress towards the completion of a mint
func get_progress(name: String) -> ChiefMintProgress:
	return ChiefMintProgress.new() if source == null else source.get_progress(name)


## Get the single completion achievement
func _get_completion_mint() -> ChiefMintResource:
	if source == null or state == null:
		return null

	for mint in state.mints:
		var is_completion = (
			mint.definition != null
			and mint.definition.rarity == ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION
		)
		if is_completion:
			return mint

	return null
