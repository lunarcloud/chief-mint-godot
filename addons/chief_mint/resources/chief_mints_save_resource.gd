@icon("res://addons/chief_mint/icon/icon.svg")
class_name ChiefMintSaveResource
extends Resource
## Chief Mint Save Resource
## A list of chief mints resources (definition and progress)

# Array<ChiefMintResource>
@export var mints: Array[Resource]


func _init():
	self.resource_name = "Chief Mint Save Resource"


# Add support for is_class
func is_class(name: String) -> bool:
	return name == "ChiefMintSaveResource" or super.is_class(name)
