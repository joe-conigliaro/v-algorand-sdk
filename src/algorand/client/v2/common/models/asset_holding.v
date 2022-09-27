module models

// AssetHolding describes an asset held by an account.
// Definition:
// data/basics/userBalance.go : AssetHolding
struct AssetHolding {
	// amount (a) number of units held.
	amount u64 [json:'amount']

	// asset_id asset ID of the holding.
	asset_id u64 [json:'asset-id']

	// deleted whether or not the asset holding is currently deleted from its account.
	deleted bool [json:'deleted,omitempty']

	// is_frozen (f) whether or not the holding is frozen.
	is_frozen bool [json:'is-frozen']

	// opted_in_at_round round during which the account opted into this asset holding.
	opted_in_at_round u64 [json:'opted-in-at-round,omitempty']

	// opted_out_at_round round during which the account opted out of this asset holding.
	opted_out_at_round u64 [json:'opted-out-at-round,omitempty']
}
