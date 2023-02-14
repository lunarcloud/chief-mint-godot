extends Node


var definitions: ChiefMintDefinitionsResource
var state: Array = [] # ChiefMintResource
var source #: ChiefMintSource

signal OnLoadedFromSource()
signal OnProgressChanged(ChiefMintResource)

func _ready():
	pass # Replace with function body.


func init_resource_from_def(def: ChiefMintDefinitionResource) -> ChiefMintResource:
	var res := ChiefMintResource.new()
	res.definition = def
	res.progress = ChiefMintProgress.new()
	return res


func load_from_source() -> void:
	pass


func get_source_name() -> String:
	return "" # TODO


func set_progress(name, value) -> void:
	pass


func get_progress(name): # -> ChiefMintProgressResource:
	return null  # TODO


