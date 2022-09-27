module types

// This file has the applications specific structures

pub struct ApplicationFields {
	ApplicationCallTxnFields
}

// AppIndex is the unique integer index of an application that can be used to
// look up the creator of the application, whose balance record contains the
// AppParams
type AppIndex = u64

pub const (
	// encoded_max_application_args sets the allocation bound for the maximum
	// number of ApplicationArgs that a transaction decoded off of the wire
	// can contain. Its value is verified against consensus parameters in
	// TestEncodedAppTxnAllocationBounds
	encoded_max_application_args = 32

	// encoded_max_accounts sets the allocation bound for the maximum number
	// of Accounts that a transaction decoded off of the wire can contain.
	// Its value is verified against consensus parameters in
	// TestEncodedAppTxnAllocationBounds
	encoded_max_accounts = 32

	// encoded_max_foreign_apps sets the allocation bound for the maximum
	// number of ForeignApps that a transaction decoded off of the wire can
	// contain. Its value is verified against consensus parameters in
	// TestEncodedAppTxnAllocationBounds
	encoded_max_foreign_apps = 32

	// encoded_max_foreign_assets sets the allocation bound for the maximum
	// number of ForeignAssets that a transaction decoded off of the wire
	// can contain. Its value is verified against consensus parameters in
	// TestEncodedAppTxnAllocationBounds
	encoded_max_foreign_assets = 32
)

// OnCompletion is an enum representing some layer 1 side effect that an
// ApplicationCall transaction will have if it is included in a block.
//go:generate stringer -type=OnCompletion -output=application_string.go

pub enum OnCompletion {
	// no_op_oc indicates that an application transaction will simply call its
	// ApprovalProgram
	no_op_oc

	// opt_in_oc indicates that an application transaction will allocate some
	// LocalState for the application in the sender's account
	opt_in_oc

	// close_out_oc indicates that an application transaction will deallocate
	// some LocalState for the application from the user's account
	close_out_oc

	// clear_state_oc is similar to close_out_oc, but may never fail. This
	// allows users to reclaim their minimum balance from an application
	// they no longer wish to opt in to.
	clear_state_oc

	// update_application_oc indicates that an application transaction will
	// update the ApprovalProgram and ClearStateProgram for the application
	update_application_oc

	// delete_application_oc indicates that an application transaction will
	// delete the AppParams for the application from the creator's balance
	// record
	delete_application_oc
}

// ApplicationCallTxnFields captures the transaction fields used for all
// interactions with applications
pub struct ApplicationCallTxnFields {
	// struct_ struct{} [codec:',omitempty,omitemptyarray']

	application_id   AppIndex     [codec:'apid']
	on_completion    OnCompletion [codec:'apan']
	application_args [][]u8     [codec:'apaa,allocbound=encoded_max_application_args']
	accounts         []Address    [codec:'apat,allocbound=encoded_max_accounts']
	foreign_apps     []AppIndex   [codec:'apfa,allocbound=encoded_max_foreign_apps']
	foreign_assets   []AssetIndex [codec:'apas,allocbound=encoded_max_foreign_assets']

	local_state_schema  StateSchema [codec:'apls']
	global_state_schema StateSchema [codec:'apgs']
	approval_program    []u8      [codec:'apap']
	clear_state_program []u8      [codec:'apsu']
	extra_program_pages u32      [codec:'apep']

	// If you add any fields here, remember you MUST modify the Empty
	// method below!
}

// StateSchema sets maximums on the number of each type that may be stored
pub struct StateSchema {
	// struct_ struct{} [codec:',omitempty,omitemptyarray']

	num_uint       u64 [codec:'nui']
	num_byte_slice u64 [codec:'nbs']
}

const empty_state_scheme = StateSchema{}

// empty indicates whether or not all the fields in the
// ApplicationCallTxnFields are zeroed out
pub fn (ac &ApplicationCallTxnFields) empty() bool {
	if ac.application_id != 0 {
		return false
	}
	if ac.on_completion != .no_op_oc {
		return false
	}
	// if ac.application_args != nil {
	// TODO: (array.len == 0) != nil slice
	if ac.application_args.len != 0 {
		return false
	}
	// if ac.accounts != nil {
	if ac.accounts.len != 0 {
		return false
	}
	// if ac.foreign_apps != nil {
	if ac.foreign_apps.len != 0 {
		return false
	}
	// if ac.foreign_assets != nil {
	if ac.foreign_assets.len != 0 {
		return false
	}
	// if ac.local_state_schema != (StateSchema{}) {
	if ac.local_state_schema != empty_state_scheme {
		return false
	}
	// if ac.global_state_schema != (StateSchema{}) {
	if ac.global_state_schema != empty_state_scheme {
		return false
	}
	// if ac.approval_program != nil {
	if ac.approval_program.len != 0 {
		return false
	}
	// if ac.clear_state_program != nil {
	if ac.clear_state_program.len != 0 {
		return false
	}
	if ac.extra_program_pages != 0 {
		return false
	}
	return true
}
