@tool
extends Resource
class_name FKSheetVarDef
## Typed definition for a sheet-local variable (s_name in expressions).

@export var var_name: String = ""
@export_enum("int", "float", "bool", "string", "Variant") var var_type: String = "Variant"
@export var default_value: Variant = null


func to_dict() -> Dictionary:
	return {
		"name": var_name,
		"type": var_type,
		"default": default_value
	}


static func from_dict(d: Dictionary) -> FKSheetVarDef:
	var def := FKSheetVarDef.new()
	if d == null:
		return def
	def.var_name = str(d.get("name", "")).strip_edges()
	def.var_type = str(d.get("type", "Variant"))
	if def.var_type.is_empty():
		def.var_type = "Variant"
	def.default_value = d.get("default", null)
	return def


static func coerce_default(value: Variant, type_name: String) -> Variant:
	match type_name:
		"int":
			return int(value) if value != null else 0
		"float":
			return float(value) if value != null else 0.0
		"bool":
			if value is bool:
				return value
			if value is String:
				return value.to_lower() in ["true", "1", "yes"]
			return bool(value) if value != null else false
		"string", "String":
			return str(value) if value != null else ""
		_:
			return value
