class_name ChiefMintProgress, "res://addons/chief_mint/icon/icon.svg"
extends Resource

export var current: int
export var maximum: int


func _init():
	self.resource_name = "Chief Mint Progress Resource"


# Add support for is_class
func is_class(name : String) -> bool:
	return name == "ChiefMintProgressResource" or .is_class(name)


func is_complete() -> bool:
	return current >= maximum
