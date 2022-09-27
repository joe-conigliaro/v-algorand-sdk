module types

// Transaction describes a transaction that can appear in a block.
pub struct Transaction {
	// Common fields for all types of transactions
	Header
	// Fields for different types of transactions
	// KeyregTxnFields
	PaymentTxnFields
	// TODO: skip empty or refactor this
	// AssetConfigTxnFields
	// AssetTransferTxnFields
	// AssetFreezeTxnFields
	// ApplicationFields
pub:
	// struct_ struct{} [codec:',omitempty,omitemptyarray']

	// Type of transaction
	//  TODO:
	// type_ TxType [codec:'type']
	type_ string [codec:'type']
}

// SignedTxn wraps a transaction and a signature. The encoding of this struct
// is suitable to broadcast on the network
[codec: 'omitempty,omitemptyarray']
pub struct SignedTxn {
pub mut:
	// struct_   struct{} 	  [codec: ',omitempty,omitemptyarray']

	sig       Signature   [codec: 'sig']
	// sig       []u8   	  [codec: 'sig']
	msig      MultisigSig [codec: 'msig']
	lsig      LogicSig    [codec: 'lsig']
	txn       Transaction [codec: 'txn']
	auth_addr Address     [codec: 'sgnr']
}

// KeyregTxnFields captures the fields used for key registration transactions.
[codec:',omitempty,omitemptyarray']
pub struct KeyregTxnFields {
	// struct_ struct{} [codec:',omitempty,omitemptyarray']

	vote_pk           VotePK         [codec:'votekey']
	selection_pk      VRFPK          [codec:'selkey']
	// TODO:
	// vote_first        Round          [codec:'votefst']
	// vote_last         Round          [codec:'votelst']
	vote_first        u64          [codec:'votefst']
	vote_last         u64          [codec:'votelst']
	vote_key_dilution u64         [codec:'votekd']
	nonparticipation  bool           [codec:'nonpart']
	state_proof_pk    MerkleVerifier [codec:'sprfkey']
}

// PaymentTxnFields captures the fields used by payment transactions.
[codec:',omitempty,omitemptyarray']
pub struct PaymentTxnFields {
	// struct_ struct{} [codec:',omitempty,omitemptyarray']

	receiver Address    [codec:'rcv']
	// amount   MicroAlgos [codec:'amt']
	amount   u64 [codec:'amt']

	// When close_remainder_to is set, it indicates that the
	// transaction is requesting that the account should be
	// closed, and all remaining funds be transferred to this
	// address.
	close_remainder_to Address [codec:'close']
}

// AssetConfigTxnFields captures the fields used for asset
// allocation, re-configuration, and destruction.
[codec:',omitempty,omitemptyarray']
pub struct AssetConfigTxnFields {
	// struct_ struct{} [codec:',omitempty,omitemptyarray']

	// config_asset is the asset being configured or destroyed.
	// A zero value means allocation.
	config_asset AssetIndex [codec:'caid']

	// asset_params are the parameters for the asset being
	// created or re-configured.  A zero value means destruction.
	asset_params AssetParams [codec:'apar']
}

// AssetTransferTxnFields captures the fields used for asset transfers.
[codec:',omitempty,omitemptyarray']
pub struct AssetTransferTxnFields {
	// struct_ struct{} [codec:',omitempty,omitemptyarray']

	xfer_asset AssetIndex [codec:'xaid']

	// asset_amount is the amount of asset to transfer.
	// A zero amount transferred to self allocates that asset
	// in the account's Assets map.
	asset_amount u64 [codec:'aamt']

	// asset_sender is the sender of the transfer.  If this is not
	// a zero value, the real transaction sender must be the Clawback
	// address from the AssetParams.  If this is the zero value,
	// the asset is sent from the transaction's Sender.
	asset_sender Address [codec:'asnd']

	// asset_receiver is the recipient of the transfer.
	asset_receiver Address [codec:'arcv']

	// asset_close_to indicates that the asset should be removed
	// from the account's Assets map, and specifies where the remaining
	// asset holdings should be transferred.  It's always valid to transfer
	// remaining asset holdings to the creator account.
	asset_close_to Address [codec:'aclose']
}

// AssetFreezeTxnFields captures the fields used for freezing asset slots.
[codec:',omitempty,omitemptyarray']
pub struct AssetFreezeTxnFields {
	// struct_ struct{} [codec:',omitempty,omitemptyarray']

	// freeze_account is the address of the account whose asset
	// slot is being frozen or un-frozen.
	freeze_account Address [codec:'fadd']

	// freeze_asset is the asset ID being frozen or un-frozen.
	freeze_asset AssetIndex [codec:'faid']

	// asset_frozen is the new frozen value.
	asset_frozen bool [codec:'afrz']
}

// Header captures the fields common to every transaction type.
[codec:',omitempty,omitemptyarray']
pub struct Header {
pub mut:
	// struct_ struct{} [codec:',omitempty,omitemptyarray']

	sender       Address    [codec:'snd']
	// TODO:
	// fee          MicroAlgos [codec:'fee']
	// first_valid  Round      [codec:'fv']
	// last_valid   Round      [codec:'lv']
	fee          u64 [codec:'fee']
	first_valid  u64      [codec:'fv']
	last_valid   u64      [codec:'lv']
	note         []u8       [codec:'note']
	genesis_id   string     [codec:'gen']
	genesis_hash Digest     [codec:'gh']

	// Group specifies that this transaction is part of a
	// transaction group (and, if so, specifies the hash
	// of a TxGroup).
	group Digest [codec:'grp']

	// lease enforces mutual exclusion of transactions.  If this field is
	// nonzero, then once the transaction is confirmed, it acquires the
	// lease identified by the (sender, lease) pair of the transaction until
	// the LastValid round passes.  While this transaction possesses the
	// lease, no other transaction specifying this lease can be confirmed.
	lease [32]u8 [codec:'lx']

	// rekey_to, if nonzero, sets the sender's SpendingKey to the given address
	// If the rekey_to address is the sender's actual address, the SpendingKey is set to zero
	// This allows "re-keying" a long-lived account -- rotating the signing key, changing
	// membership of a multisig account, etc.
	rekey_to Address [codec:'rekey']
}

// TxGroup describes a group of transactions that must appear
// together in a specific order in a block.
pub struct TxGroup {
pub mut:
	// struct_ struct{} [codec:',omitempty,omitemptyarray']

	// tx_group_hashes specifies a list of hashes of transactions that must appear
	// together, sequentially, in a block in order for the group to be
	// valid.  Each hash in the list is a hash of a transaction with
	// the `Group` field omitted.
	tx_group_hashes []Digest [codec:'txlist']
}

// SuggestedParams wraps the transaction parameters common to all transactions,
// typically received from the SuggestedParams endpoint of algod.
// This struct itself is not sent over the wire to or from algod: see models.TransactionParams.
pub struct SuggestedParams {
pub:
	// Fee is the suggested transaction fee
	// Fee is in units of micro-Algos per byte.
	// Fee may fall to zero but a group of N atomic transactions must
	// still have a fee of at least N*MinTxnFee for the current network protocol.
	fee MicroAlgos [codec:'fee']

	// Genesis ID
	genesis_id string [codec:'genesis-id']

	// Genesis hash
	genesis_hash []u8 [codec:'genesis-hash']

	// FirstRoundValid is the first protocol round on which the txn is valid
	first_round_valid Round [codec:'first-round']

	// LastRoundValid is the final protocol round on which the txn may be committed
	last_round_valid Round [codec:'last-round']

	// ConsensusVersion indicates the consensus protocol version
	// as of LastRound.
	consensus_version string [codec:'consensus-version']

	// FlatFee indicates whether the passed fee is per-byte or per-transaction
	// If true, txn fee may fall below the MinTxnFee for the current network protocol.
	flat_fee bool [codec:'flat-fee']

	// The minimum transaction fee (not per byte) required for the
	// txn to validate for the current network protocol.
	min_fee u64 [codec:'min-fee']
}

// // AddLease adds the passed lease (see types/transaction.go) to the header of the passed transaction
// // and updates fee accordingly
// // - lease: the [32]byte lease to add to the header
// // - feePerByte: the new feePerByte
// func (tx *Transaction) AddLease(lease [32]byte, feePerByte u64) {
// 	copy(tx.Header.Lease[:], lease[:])
// 	// normally we would use estimateSize,
// 	// and set fee = feePerByte * estimateSize,
// 	// but this would cause a circular import.
// 	// we know we are adding 32 bytes (+ a few bytes to hold the 32), so increase fee accordingly.
// 	tx.Header.Fee = tx.Header.Fee + MicroAlgos(37*feePerByte)
// }

// // AddLeaseWithFlatFee adds the passed lease (see types/transaction.go) to the header of the passed transaction
// // and updates fee accordingly
// // - lease: the [32]byte lease to add to the header
// // - flatFee: the new flatFee
// func (tx *Transaction) AddLeaseWithFlatFee(lease [32]byte, flatFee u64) {
// 	tx.Header.Lease = lease
// 	tx.Header.Fee = MicroAlgos(flatFee)
// }

// // Rekey sets the rekeyTo field to the passed address. Any future transacrtion will need to be signed by the
// // rekeyTo address' corresponding private key.
// func (tx *Transaction) Rekey(rekeyToAddress string) error {
// 	addr, err := DecodeAddress(rekeyToAddress)
// 	if err != nil {
// 		return err
// 	}

// 	tx.RekeyTo = addr
// 	return nil
// }
