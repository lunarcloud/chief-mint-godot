class_name ChiefMintDefinitionResource, "res://addons/chief_mint/icon/icon.svg"
extends Resource

export var name: String
export(int, 1, 255, 1) var maximum_progress: int
export var display_partial_progress: bool = true

func _init():
	self.resource_name = "Chief Mint Definition Resource"

# Add support for is_class
func is_class(name : String) -> bool:
	return name == "ChiefMintDefinitionResource" or .is_class(name)
