class_name ChiefMintDefinitionsResource
extends Resource
## Chief Mint Definitions Resource
## List of mint definitions

@export var definitions: Array[Resource]


func _init():
	self.resource_name = "Chief Mint Definitions Resource"


# Add support for is_class
func is_class(name: String) -> bool:
	return name == "ChiefMintDefinitionsResource" or .is_class(name)
