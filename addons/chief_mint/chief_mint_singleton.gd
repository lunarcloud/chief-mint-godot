extends Node
class_name ChiefMintSingleton

var state #: ChiefMintSaveResource
var source #: ChiefMintSource

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


func get_source_name() -> String:
	return "error" if source == null else source.get_source_name()


func increment_progress(name: String) -> void:
	if source != null:
		var resource = source.increment_progress(name)
		emit_signal("progress_changed", resource)


func set_progress(name: String, value) -> void:
	if source != null:
		var resource = source.set_progress(name, value)
		emit_signal("progress_changed", resource)


func get_progress(name: String) -> ChiefMintProgress:
	return null if source == null else source.get_progress(name)

