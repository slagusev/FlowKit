extends Node2D
## Full-loop demo host. Sheet logic comes from imported FlowKit sheet JSON.
## Press Space → engine should Call Subsheet add_score if sheet is set up.

@onready var score_label: Label = %ScoreLabel
@onready var status_label: Label = %StatusLabel

func _ready() -> void:
	status_label.text = "Running. F4 debug · Space awards score if sheet imported."
	_refresh_score()

func _process(_delta: float) -> void:
	_refresh_score()
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
		# Fallback if sheet not wired: still show how system vars work
		var system = get_node_or_null("/root/FlowKitSystem")
		if system and system.has_method("get_sheet_var"):
			if not system.has_sheet_var("score"):
				# Demo without sheet: local bump
				if not system.has_var("demo_score"):
					system.set_var("demo_score", 0)
				system.set_var("demo_score", int(system.get_var("demo_score", 0)) + 1)

func _refresh_score() -> void:
	if score_label == null:
		return
	var system = get_node_or_null("/root/FlowKitSystem")
	if system == null:
		score_label.text = "Score: (no FlowKitSystem)"
		return
	var s = 0
	if system.has_method("has_sheet_var") and system.has_sheet_var("score"):
		s = system.get_sheet_var("score", 0)
	elif system.has_method("get_var"):
		s = system.get_var("demo_score", 0)
	score_label.text = "Score: %s" % str(s)
