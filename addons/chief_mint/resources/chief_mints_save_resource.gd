class_name ChiefMintSaveResource, "res://addons/chief_mint/icon/icon.svg"
extends Resource
## Chief Mint Save Resource
## A list of chief mints resources (definition and progress)

# Array<ChiefMintResource>
export(Array, Resource) var mints: Array


func _init():
	self.resource_name = "Chief Mint Save Resource"


# Add support for is_class
func is_class(name: String) -> bool:
	return name == "ChiefMintSaveResource" or .is_class(name)
