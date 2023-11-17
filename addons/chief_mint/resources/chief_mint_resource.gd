class_name ChiefMintResource, "res://addons/chief_mint/icon/icon.svg"
extends Resource
## Chief Mint Resource
## The definition and current progress

export(Resource) var definition: Resource  #: ChiefMintDefinitionResource
export(Resource) var progress: Resource  #: ChiefMintProgress


func _init():
	self.resource_name = "Chief Mint Resource"


# Add support for is_class
func is_class(name: String) -> bool:
	return name == "ChiefMintResource" or .is_class(name)
