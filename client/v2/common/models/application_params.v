module models

// ApplicationParams stores the global information associated with an application.
struct ApplicationParams {
	// approval_program (approv) approval program.
	approval_program []u8 [json:'approval-program']

	// clear_state_program (clearp) approval program.
	clear_state_program []u8 [json:'clear-state-program']

	// creator the address that created this application. This is the address where the
	// parameters and global state for this application can be found.
	creator string [json:'creator,omitempty']

	// extra_program_pages (epp) the amount of extra program pages available to this app.
	extra_program_pages u64 [json:'extra-program-pages,omitempty']

	// global_state [\gs) global schema
	global_state []TealKeyValue [json:'global-state,omitempty']

	// global_state_schema [\gsch) global schema
	global_state_schema ApplicationStateSchema [json:'global-state-schema,omitempty']

	// local_state_schema [\lsch) local schema
	local_state_schema ApplicationStateSchema [json:'local-state-schema,omitempty']
}
