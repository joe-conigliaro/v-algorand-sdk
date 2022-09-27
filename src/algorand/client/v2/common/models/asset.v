module models

// Asset specifies both the unique identifier and the parameters for an asset
struct Asset {
	// created_at_round round during which this asset was created.
	created_at_round u64 [json:'created-at-round,omitempty']

	// deleted whether or not this asset is currently deleted.
	deleted bool [json:'deleted,omitempty']

	// destroyed_at_round round during which this asset was destroyed.
	destroyed_at_round u64 [json:'destroyed-at-round,omitempty']

	// index unique asset identifier
	index u64 [json:'index']

	// params assetParams specifies the parameters for an asset.
	// (apar) when part of an AssetConfig transaction.
	// Definition:
	// data/transactions/asset.go : AssetParams
	params AssetParams [json:'params']
}
