module models

// TealValue represents a TEAL value.
struct TealValue {
	// bytes (tb) bytes value.
	bytes string [json:'bytes']

	// type_ (tt) value type. Value `1` refers to **bytes**, value `2` refers to
	// **uint**
	type_ u64 [json:'type']

	// uint (ui) uint value.
	uint u64 [json:'uint']
}
