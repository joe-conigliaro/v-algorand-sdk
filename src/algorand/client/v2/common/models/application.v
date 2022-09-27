module models

// Application application index and its parameters
struct Application {
	// CreatedAtRound round when this application was created.
	created_at_round u64 [json:'created-at-round,omitempty']

	// deleted whether or not this application is currently deleted.
	deleted bool [json:'deleted,omitempty']

	// deleted_at_round round when this application was deleted.
	deleted_at_round u64 [json:'deleted-at-round,omitempty']

	// id (appidx) application index.
	id u64 [json:'id']

	// params (appparams) application parameters.
	params ApplicationParams [json:'params']
}
