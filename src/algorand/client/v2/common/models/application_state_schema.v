module models

// ApplicationStateSchema specifies maximums on the number of each type that may be
// stored.
struct ApplicationStateSchema {
	// num_byte_slice (nbs) num of byte slices.
	num_byte_slice u64 [json:'num-byte-slice']

	// num_uint (nui) num of uints.
	num_uint u64 [json:'num-uint']
}
