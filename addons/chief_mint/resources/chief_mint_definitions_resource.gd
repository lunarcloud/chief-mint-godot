class_name ChiefMintDefinitionsResource, "res://addons/chief_mint/icon/icon.svg"
extends Resource
## Chief Mint Definitions Resource
## List of mint definitions

export(Array, Resource) var definitions: Array


func _init():
	self.resource_name = "Chief Mint Definitions Resource"


# Add support for is_class
func is_class(name: String) -> bool:
	return name == "ChiefMintDefinitionsResource" or .is_class(name)
