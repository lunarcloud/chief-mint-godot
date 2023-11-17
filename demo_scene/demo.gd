extends Control

onready var chief_mints : ChiefMintSingleton = $"/root/ChiefMint"


func _on_RareEventButton_pressed():
	chief_mints.increment_progress("Rare Event")


func _on_HatTrickProgressButton_pressed():
	chief_mints.increment_progress("Hat Trick")


func _on_CommonEventButton_pressed():
	chief_mints.increment_progress("commonish")


func _on_ClearLocalButton_pressed():
	chief_mints.clear_all_progress()
