module models

// TransactionParametersResponse transactionParams contains the parameters that
// help a client construct a new transaction.
struct TransactionParametersResponse {
	// ConsensusVersion consensusVersion indicates the consensus protocol version
	// as of LastRound.
	consensus_version string [json:'consensus-version']

	// Fee fee is the suggested transaction fee
	// Fee is in units of micro-Algos per byte.
	// Fee may fall to zero but transactions must still have a fee of
	// at least MinTxnFee for the current network protocol.
	fee u64 [json:'fee']

	// GenesisHash genesisHash is the hash of the genesis block.
	genesis_hash []u8 [json:'genesis-hash']

	// GenesisId genesisID is an ID listed in the genesis block.
	genesis_id string [json:'genesis-id']

	// LastRound lastRound indicates the last round seen
	last_round u64 [json:'last-round']

	// MinFee the minimum transaction fee (not per byte) required for the
	// txn to validate for the current network protocol.
	min_fee u64 [json:'min-fee']
}
