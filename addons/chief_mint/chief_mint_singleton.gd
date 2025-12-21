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

		# Track completion achievements before the increment
		var completion_achievements_before = _get_incomplete_completion_achievements()

		var resource = source.increment_progress(name)
		var changed = old_progress != resource.progress.current
		if changed:
			progress_changed.emit(resource)

			# Check for newly completed completion achievements
			var completion_achievements_after = _get_incomplete_completion_achievements()
			# Convert to dictionary for O(1) lookup
			var after_dict = {}
			for mint_name in completion_achievements_after:
				after_dict[mint_name] = true

			for mint_name in completion_achievements_before:
				if not after_dict.has(mint_name):
					# This completion achievement just became complete
					var completed_mint = _get_mint_by_name(mint_name)
					if completed_mint != null:
						progress_changed.emit(completed_mint)


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


## Get list of incomplete completion achievement names
func _get_incomplete_completion_achievements() -> Array[String]:
	var incomplete: Array[String] = []
	if source == null or state == null:
		return incomplete

	for mint in state.mints:
		var is_completion_rarity = (
			mint.definition != null
			and mint.definition.rarity == ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION
		)
		if is_completion_rarity and not mint.progress.is_complete():
			incomplete.append(mint.definition.name)

	return incomplete


## Get a mint resource by name
func _get_mint_by_name(mint_name: String) -> ChiefMintResource:
	if source == null or state == null:
		return null

	for mint in state.mints:
		if mint.definition != null and mint.definition.name == mint_name:
			return mint

	return null
