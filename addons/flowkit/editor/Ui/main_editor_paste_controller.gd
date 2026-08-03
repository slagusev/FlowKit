extends RefCounted
class_name FKMainEditorPasteController
## Paste helpers extracted from FKMainEditor (architecture debt).

var editor: FKMainEditor


func setup(main: FKMainEditor) -> void:
	editor = main


func paste_events() -> void:
	if editor:
		editor._paste_events()


func paste_actions() -> void:
	if editor:
		editor._paste_actions()


func paste_conditions() -> void:
	if editor:
		editor._paste_conditions()


func paste_group() -> void:
	if editor:
		editor._paste_group()
