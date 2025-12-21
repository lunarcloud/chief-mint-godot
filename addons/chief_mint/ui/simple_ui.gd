class_name ChiefMintSimpleUi
extends Control
## Simple ChiefMint Notification UI
## A simple, 2D "toaster" style popup

@export var display_time := 2.0

var _current_notify = 0
var _notification_queue: Array[ChiefMintResource] = []
var _is_displaying := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var chief_mints: ChiefMintSingleton = $"/root/ChiefMint"

@onready var icon: TextureRect = $Panel/HBoxContainer/Container/Icon
@onready var name_label: Label = $Panel/HBoxContainer/VBoxContainer/Name
@onready var description_label: Label = $Panel/HBoxContainer/VBoxContainer/Description
@onready var progressbar: ProgressBar = $Panel/HBoxContainer/VBoxContainer/ProgressBar


func _ready():
	chief_mints.progress_changed.connect(notify)


func notify(res: ChiefMintResource) -> void:
	if res == null:
		push_warning("Notified about null mint")
		return

	# Remove any existing notification for this achievement (keep only the latest state)
	for i in range(_notification_queue.size() - 1, -1, -1):
		if _notification_queue[i].definition.name == res.definition.name:
			_notification_queue.remove_at(i)

	# Check if this is a completion achievement
	var is_completion = (
		res.definition != null
		and res.definition.rarity == ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION
	)

	if is_completion:
		# Completion achievements always go to the end of the queue
		_notification_queue.append(res)
	else:
		# Regular achievements: insert before any completion achievement
		var completion_index = -1
		for i in range(_notification_queue.size()):
			var queue_item = _notification_queue[i]
			var is_completion_in_queue = (
				queue_item.definition.rarity == ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION
			)
			if is_completion_in_queue:
				completion_index = i
				break

		if completion_index >= 0:
			# Insert before the completion achievement
			_notification_queue.insert(completion_index, res)
		else:
			# No completion achievement in queue, just append
			_notification_queue.append(res)

	# Start processing the queue if not already displaying
	if not _is_displaying:
		_process_queue()


func _process_queue() -> void:
	_is_displaying = true

	while _notification_queue.size() > 0:
		var res: ChiefMintResource = _notification_queue.pop_front()

		# Update UI with the current achievement
		name_label.text = res.definition.name
		description_label.text = res.definition.description

		if res.definition.icon != null:
			var texture = ImageTexture.create_from_image(res.definition.icon)
			icon.texture = texture

		progressbar.visible = res.progress.maximum > 1
		progressbar.max_value = res.progress.maximum
		progressbar.value = res.progress.current

		# Display the achievement
		await _show()

	_is_displaying = false


func _show(seconds: float = display_time):
	if animation_player.current_animation:
		await animation_player.animation_finished

	var id = Time.get_ticks_msec()
	_current_notify = id

	animation_player.play("Show")
	await animation_player.animation_finished
	await get_tree().create_timer(seconds).timeout
	await _hide(id)


func _hide(id: int) -> void:
	if _current_notify != id:
		return  # The notification has been replaced

	animation_player.play("Hide")
	await animation_player.animation_finished
	animation_player.play("Hidden")
