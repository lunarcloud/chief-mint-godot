extends Node


func _ready():
	pass # Replace with function body.


func init_resource_from_def(def: ChiefMintDefinitionResource) -> ChiefMintResource:
	var res := ChiefMintResource.new()
	res.definition = def
	res.progress = ChiefMintProgress.new()
	return res

