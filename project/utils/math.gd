class_name MathUtils


static func sumi(a: int, b: int) -> int:
	return a + b

# inclusive on both sides
static func in_range_ii(a: float, min: float, max: float) -> bool:
	return a >= min and a <= max

# inclusive on min, exclusive on max
static func in_range_ie(a: float, min: float, max: float) -> bool:
	return a >= min and a < max

static func factorial(n: int) -> int:
	if(n == 1):
		return 1
	else:
		return n * factorial(n-1)
