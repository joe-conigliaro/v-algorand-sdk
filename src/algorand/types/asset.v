module types

pub const(
	// asset_name_max_len is the max length in bytes for the asset name
	asset_name_max_len = 32

	// asset_unit_name_max_len is the max length in bytes for the asset unit name
	asset_unit_name_max_len = 8

	// asset_url_max_len is the max length in bytes for the asset url
	asset_url_max_len = 96

	// asset_metadata_hash_len is the length of the AssetMetadataHash in bytes
	asset_metadata_hash_len = 32

	// asset_max_number_of_decimals is the maximum value of the Decimals field
	asset_max_number_of_decimals = 19
)

// AssetIndex is the unique integer index of an asset that can be used to look
// up the creator of the asset, whose balance record contains the AssetParams
type AssetIndex = u64

// AssetParams describes the parameters of an asset.
pub struct AssetParams {
	// struct_ struct{} [codec:',omitempty,omitemptyarray']

	// total specifies the total number of units of this asset
	// created.
	total u64 [codec:'t']

	// decimals specifies the number of digits to display after the decimal
	// place when displaying this asset. A value of 0 represents an asset
	// that is not divisible, a value of 1 represents an asset divisible
	// into tenths, and so on. This value must be between 0 and 19
	// (inclusive).
	decimals u32 [codec:'dc']

	// default_frozen specifies whether slots for this asset
	// in user accounts are frozen by default or not.
	default_frozen bool [codec:'df']

	// unit_name specifies a hint for the name of a unit of
	// this asset.
	unit_name string [codec:'un']

	// asset_name specifies a hint for the name of the asset.
	asset_name string [codec:'an']

	// url specifies a URL where more information about the asset can be
	// retrieved
	url string [codec:'au']

	// metadata_hash specifies a commitment to some unspecified asset
	// metadata. The format of this metadata is up to the application.
	metadata_hash [asset_metadata_hash_len]u8 [codec:'am']

	// manager specifies an account that is allowed to change the
	// non-zero addresses in this AssetParams.
	manager Address [codec:'m']

	// reserve specifies an account whose holdings of this asset
	// should be reported as "not minted".
	reserve Address [codec:'r']

	// freeze specifies an account that is allowed to change the
	// frozen state of holdings of this asset.
	freeze Address [codec:'f']

	// clawback specifies an account that is allowed to take units
	// of this asset from any account.
	clawback Address [codec:'c']
}

const zero_ap = AssetParams{}

// IsZero returns true if the AssetParams struct is completely empty.
// The AssetParams zero object is used in destroying an asset.
pub fn (ap AssetParams) is_zero() bool {
	return ap == zero_ap
}
