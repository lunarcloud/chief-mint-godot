class_name ChiefMintDefinitionResource, "res://addons/chief_mint/icon/icon.svg"
extends Resource

enum ChiefMintRarity {
	Common = 0,
	Uncommon,
	Rare,
	Completion
}


export var name: String

export var description: String

export var icon_path: String

export(int, 1, 255, 1) var maximum_progress: int

export var display_partial_progress: bool = true

export(int, "Common", "Uncommon", "Rare", "Completion") var rarity := ChiefMintRarity.Common


func _init():
	self.resource_name = "Chief Mint Definition Resource"

# Add support for is_class
func is_class(name : String) -> bool:
	return name == "ChiefMintDefinitionResource" or .is_class(name)
