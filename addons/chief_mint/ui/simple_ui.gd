extends Control
class_name ChiefMintSimpleUi


onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var chief_mints : ChiefMintSingleton = $"/root/ChiefMint"

onready var icon : TextureRect = $Panel/HBoxContainer/Container/Icon
onready var name_label : Label = $Panel/HBoxContainer/VBoxContainer/Name
onready var description_label : Label = $Panel/HBoxContainer/VBoxContainer/Description
onready var progressbar : ProgressBar = $Panel/HBoxContainer/VBoxContainer/ProgressBar


func _ready():
	chief_mints.connect("progress_changed", self, "notify")


func notify(res: ChiefMintResource) -> void:
	if res == null:
		push_warning("Notified about null mint")
		return
	
	name_label.text = res.definition.name
	description_label.text = res.definition.description
	
	var icon_tex : ImageTexture = icon.texture
	icon_tex.resource_path = res.definition.icon_path
	
	progressbar.visible = res.progress.maximum > 1
	progressbar.max_value = res.progress.maximum
	progressbar.value = res.progress.current
	show()


func show(seconds : float = 2):
	animation_player.play("Show")
	if seconds != null and seconds > 0:
		animation_player.connect("animation_finished", self, "hide", [seconds], CONNECT_ONESHOT)


func hide(seconds : float = 0):
	if seconds != null and seconds > 0:
		yield(get_tree().create_timer(seconds), "timeout")
	animation_player.play("Hide")
