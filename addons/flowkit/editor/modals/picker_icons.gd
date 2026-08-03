extends RefCounted
class_name FKPickerIcons
## Text/emoji icons for provider pickers (no EditorIcons dependency).

static func for_category(category: String) -> String:
	var c := category.strip_edges()
	match c:
		"System":
			return "⚙ "
		"Node":
			return "● "
		"Node2D", "CharacterBody2D", "RigidBody2D", "StaticBody2D", "Area2D", \
		"Sprite2D", "AnimatedSprite2D", "Camera2D", "TileMapLayer", "PathFollow2D", \
		"CollisionObject2D", "CollisionShape2D", "Light2D", "GPUParticles2D", \
		"CPUParticles2D", "NavigationAgent2D", "RayCast2D", "VisibleOnScreenNotifier2D":
			return "🟩 "
		"Node3D", "CharacterBody3D", "RigidBody3D", "StaticBody3D", "Area3D", \
		"Camera3D", "Light3D", "GPUParticles3D", "CollisionObject3D", \
		"CollisionShape3D", "NavigationAgent3D", "RayCast3D", "GeometryInstance3D", \
		"VisibleOnScreenNotifier3D", "AudioStreamPlayer3D":
			return "🟦 "
		"Control", "Button", "Label", "LineEdit", "TextEdit", "Range", "ProgressBar", \
		"Slider", "HSlider", "VSlider", "OptionButton", "ItemList", "Tree", \
		"TabContainer", "PopupMenu", "Window", "FileDialog", "ColorPicker", \
		"CheckBox", "CheckButton", "RichTextLabel", "TextureRect", "Panel", \
		"CanvasItem":
			return "🟪 "
		"AnimationPlayer", "AnimationTree", "Tween", "Timer", "AudioStreamPlayer", \
		"AudioStreamPlayer2D", "VideoStreamPlayer":
			return "🎬 "
		"MultiplayerAPI":
			return "🌐 "
		_:
			if c.begins_with("UI") or c == "Ui":
				return "🟪 "
			return "○ "


static func for_provider_types(supported_types: Array) -> String:
	if supported_types.is_empty():
		return "○ "
	return for_category(str(supported_types[0]))
