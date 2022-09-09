module models

// TealKeyValue represents a key-value pair in an application store.
struct TealKeyValue {
	// Key
	key string [json:'key']

	// Value represents a TEAL value.
	value TealValue [json:'value']
}
