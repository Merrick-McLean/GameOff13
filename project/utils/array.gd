class_name ArrayUtils
extends Node



static func intersection(arr1: Array, arr2: Array) -> Array:
	var arr2_dict := {}
	for v: Variant in arr2:
		arr2_dict[v] = true
	
	var in_both_arrays := []
	for v: Variant in arr1:
		if arr2_dict.get(v, false):
			in_both_arrays.append(v)
	return in_both_arrays
