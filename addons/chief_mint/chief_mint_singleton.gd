extends Node
class_name ChiefMintSingleton

var state: ChiefMintSaveResource
var source: ChiefMintSource

signal loaded_from_source()
signal progress_changed(ChiefMintResource)

func _ready():
	var sourcePath = ProjectSettings.get_setting(ChiefMintConstants.MINT_SOURCE_SETTING)
	if sourcePath  == null or not ResourceLoader.exists(sourcePath):
		source = load(ChiefMintConstants.MINT_SOURCE_DEFAULT).new()
	else:
		source = load(sourcePath).new()

	load_from_source()


func init_resource_from_def(def: ChiefMintDefinitionResource) -> ChiefMintResource:
	var res := ChiefMintResource.new()
	res.definition = def
	res.progress = ChiefMintProgress.new()
	return res


func load_from_source() -> void:
	if source != null:
		state = source.load_saved()
		emit_signal("loaded_from_source")


func clear_all_progress() -> bool:
	return false if source == null else source.clear_all_progress()


func get_source_name() -> String:
	return "error" if source == null else source.get_source_name()


func increment_progress(name: String) -> void:
	if source != null and !is_complete(name):
		var old_progress : int = source.get_progress(name).current
		var resource = source.increment_progress(name)
		var changed = old_progress != resource.progress.current
		if changed:
			emit_signal("progress_changed", resource)


func set_progress(name: String, value) -> void:
	if source != null:
		var old_progress : int = source.get_progress(name).current
		var resource = source.set_progress(name, value)
		var changed = old_progress != resource.progress.current
		if changed:
			emit_signal("progress_changed", resource)


func is_complete(name: String) -> bool:
	return false if source == null else source.is_complete(name)


func get_progress(name: String) -> ChiefMintProgress:
	return ChiefMintProgress.new() if source == null else source.get_progress(name)

