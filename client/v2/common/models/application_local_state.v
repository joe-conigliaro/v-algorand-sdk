module models

// ApplicationLocalState stores local state associated with an application.
struct ApplicationLocalState {
	// closed_out_at_round round when account closed out of the application.
	closed_out_at_round u64 [json:'closed-out-at-round,omitempty']

	// deleted whether or not the application local state is currently deleted from its
	// account.
	deleted bool [json:'deleted,omitempty']

	// id the application which this local state is for.
	id u64 [json:'id']

	// rey_value (tkv) storage.
	rey_value []TealKeyValue [json:'key-value,omitempty']

	// opted_in_at_round round when the account opted into the application.
	opted_in_at_round u64 [json:'opted-in-at-round,omitempty']

	// schema (hsch) schema.
	schema ApplicationStateSchema [json:'schema']
}
