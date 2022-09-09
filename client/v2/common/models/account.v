module models

// Account account information at a given round.
// Definition:
// data/basics/userBalance.go : AccountData
pub struct Account {
pub:
	// Address the account public key
	address string [json: 'address']

	// Amount (algo) total number of MicroAlgos in the account
	amount u64 [json: 'amount']

	// amount_without_pending_rewards specifies the amount of MicroAlgos in the account,
	// without the pending rewards.
	amount_without_pending_rewards u64 [json: 'amount-without-pending-rewards']

	// apps_local_state (appl) applications local data stored in this account.
	// Note the raw object uses `map[int] -> AppLocalState` for this type.
	apps_local_state []ApplicationLocalState [json: 'apps-local-state,omitempty']

	// apps_total_extra_pages (teap) the sum of all extra application program pages for
	// this account.
	apps_total_extra_pages u64 [json: 'apps-total-extra-pages,omitempty']

	// apps_total_schema (tsch) stores the sum of all of the local schemas and global
	// schemas in this account.
	// Note: the raw account uses `StateSchema` for this type.
	apps_total_schema ApplicationStateSchema [json: 'apps-total-schema,omitempty']

	// Assets (asset) assets held by this account.
	// Note the raw object uses `map[int] -> AssetHolding` for this type.
	assets []AssetHolding [json: 'assets,omitempty']

	// auth_addr (spend) the address against which signing should be checked. If empty,
	// the address of the current account is used. This field can be updated in any
	// transaction by setting the RekeyTo field.
	auth_addr string [json: 'auth-addr,omitempty']

	// closed_at_round round during which this account was most recently closed.
	closed_at_round u64 [json: 'closed-at-round,omitempty']

	// created_apps (appp) parameters of applications created by this account including
	// app global data.
	// Note: the raw account uses `map[int] -> AppParams` for this type.
	created_apps []Application [json: 'created-apps,omitempty']

	// created_assets (apar) parameters of assets created by this account.
	// Note: the raw account uses `map[int] -> Asset` for this type.
	created_assets []Asset [json: 'created-assets,omitempty']

	// created_at_round round during which this account first appeared in a transaction.
	created_at_round u64 [json: 'created-at-round,omitempty']

	// deleted whether or not this account is currently closed.
	deleted bool [json: 'deleted,omitempty']

	// participation accountParticipation describes the parameters used by this account
	// in consensus protocol.
	participation AccountParticipation [json: 'participation,omitempty']

	// pending_rewards amount of MicroAlgos of pending rewards in this account.
	pending_rewards u64 [json: 'pending-rewards']

	// reward_base (ebase) used as part of the rewards computation. Only applicable to
	// accounts which are participating.
	reward_base u64 [json: 'reward-base,omitempty']

	// rewards (ern) total rewards of MicroAlgos the account has received, including
	// pending rewards.
	rewards u64 [json: 'rewards']

	// round the round for which this information is relevant.
	round u64 [json: 'round']

	// sig_type indicates what type of signature is used by this account, must be one
	// of:
	// * sig
	// * msig
	// * lsig
	// * or null if unknown
	sig_type string [json: 'sig-type,omitempty']

	// status (onl) delegation status of the account's MicroAlgos
	// * Offline - indicates that the associated account is delegated.
	// * Online - indicates that the associated account used as part of the delegation
	// pool.
	// * NotParticipating - indicates that the associated account is neither a
	// delegator nor a delegate.
	status string [json: 'status']

	// total_apps_opted_in the count of all applications that have been opted in,
	// equivalent to the count of application local data (AppLocalState objects) stored
	// in this account.
	total_apps_opted_in u64 [json: 'total-apps-opted-in']

	// total_assets_opted_in the count of all assets that have been opted in, equivalent
	// to the count of AssetHolding objects held by this account.
	total_assets_opted_in u64 [json: 'total-assets-opted-in']

	// total_created_apps the count of all apps (AppParams objects) created by this
	// account.
	total_created_apps u64 [json: 'total-created-apps']

	// total_created_assets the count of all assets (AssetParams objects) created by this
	// account.
	total_created_assets u64 [json: 'total-created-assets']
}
