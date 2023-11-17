class_name ChiefMintSimpleUi
extends Control
## Simple ChiefMint Notification UI
## A simple, 2D "toaster" style popup

export var display_time := 2.0

var _current_notify = 0

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var chief_mints: ChiefMintSingleton = $"/root/ChiefMint"

onready var icon: TextureRect = $Panel/HBoxContainer/Container/Icon
onready var name_label: Label = $Panel/HBoxContainer/VBoxContainer/Name
onready var description_label: Label = $Panel/HBoxContainer/VBoxContainer/Description
onready var progressbar: ProgressBar = $Panel/HBoxContainer/VBoxContainer/ProgressBar


func _ready():
	chief_mints.connect("progress_changed", self, "notify")


func notify(res: ChiefMintResource) -> void:
	if res == null:
		push_warning("Notified about null mint")
		return

	name_label.text = res.definition.name
	description_label.text = res.definition.description

	icon.texture.create_from_image(res.definition.icon)

	progressbar.visible = res.progress.maximum > 1
	progressbar.max_value = res.progress.maximum
	progressbar.value = res.progress.current

	_show()


func _show(seconds: float = display_time):
	if animation_player.current_animation:
		yield(animation_player, "animation_finished")

	var id = Time.get_ticks_msec()
	_current_notify = id

	animation_player.play("Show")
	yield(animation_player, "animation_finished")
	yield(get_tree().create_timer(seconds), "timeout")
	_hide(id)


func _hide(id: int) -> void:
	if _current_notify != id:
		return  # The notification has been replaced

	animation_player.play("Hide")
	yield(animation_player, "animation_finished")
	animation_player.play("Hidden")
