extends GutTest

const Eval = preload("res://addons/flowkit/runtime/expression_evaluator.gd")


func test_literal_int():
	assert_eq(Eval.evaluate("42"), 42)


func test_literal_float():
	assert_eq(Eval.evaluate("3.14"), 3.14)


func test_literal_bool_true():
	assert_eq(Eval.evaluate("true"), true)


func test_literal_bool_false():
	assert_eq(Eval.evaluate("false"), false)


func test_literal_null():
	assert_eq(Eval.evaluate("null"), null)


func test_literal_string_double_quotes():
	assert_eq(Eval.evaluate("\"hello\""), "hello")


func test_empty_expression():
	assert_eq(Eval.evaluate(""), "")


func test_vector2_literal():
	var result = Eval.evaluate("Vector2(1, 2)")
	assert_true(result is Vector2)
	assert_eq(result, Vector2(1, 2))


func test_evaluate_inputs_string_only():
	var out = Eval.evaluate_inputs({"a": "10", "b": 5})
	assert_eq(out["a"], 10)
	assert_eq(out["b"], 5)


func test_math_expression_without_context():
	# Pure math should work via Expression without a node context.
	var result = Eval.evaluate("1 + 2 * 3")
	assert_eq(result, 7)
