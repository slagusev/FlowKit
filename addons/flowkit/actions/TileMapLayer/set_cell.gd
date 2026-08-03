extends FKAction

func get_description() -> String:
	return "Sets a TileMapLayer cell (atlas coords)."

func get_id() -> String:
	return "tilemaplayer_set_cell"

func get_name() -> String:
	return "Set Cell (TileMapLayer)"

func get_supported_types() -> Array[String]:
	return ["TileMapLayer"]

func get_inputs() -> Array[FKActionInput]:
	return [_x, _y, _sx, _sy, _source]

static var _x: FKIntActionInput:
	get: return FKIntActionInput.new("X", "Cell X", 0)
static var _y: FKIntActionInput:
	get: return FKIntActionInput.new("Y", "Cell Y", 0)
static var _sx: FKIntActionInput:
	get: return FKIntActionInput.new("AtlasX", "Atlas X", 0)
static var _sy: FKIntActionInput:
	get: return FKIntActionInput.new("AtlasY", "Atlas Y", 0)
static var _source: FKIntActionInput:
	get: return FKIntActionInput.new("SourceId", "Source id", 0)

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if node is TileMapLayer:
		(node as TileMapLayer).set_cell(
			Vector2i(int(_x.get_val(inputs)), int(_y.get_val(inputs))),
			int(_source.get_val(inputs)),
			Vector2i(int(_sx.get_val(inputs)), int(_sy.get_val(inputs)))
		)
