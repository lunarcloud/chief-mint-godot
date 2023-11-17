class_name ChiefMintProgress, "res://addons/chief_mint/icon/icon.svg"
extends Resource
## Chief Mint Progress Resource
## The current and max progress that has been made towards an achievement

export var current: int
export var maximum: int


func _init():
	self.resource_name = "Chief Mint Progress Resource"


# Add support for is_class
func is_class(name: String) -> bool:
	return name == "ChiefMintProgressResource" or .is_class(name)


## Has the current value reached the completion amount?
func is_complete() -> bool:
	return current >= maximum
