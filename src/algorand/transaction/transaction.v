module transaction

import encoding.base64
// import encoding.msgpack
import msgpack
import algorand.crypto2 as crypto
import algorand.types

pub const(
	// min_txn_fee is v5 consensus params, in microAlgos
	min_txn_fee = 1000

	// num_of_additional_bytes_after_signing is the number of bytes added to a txn after signing it
	num_of_additional_bytes_after_signing = 75
)

// make_payment_txn constructs a payment transaction using the passed parameters.
// `from` and `to` addresses should be checksummed, human-readable addresses
// fee is fee per byte as received from algod SuggestedFee API call
// Deprecated: next major version will use a Params object, see package future
pub fn make_payment_txn(from string, to string, fee u64, amount u64, first_round u64, last_round u64, note []u8, close_remainder_to string, genesis_id string, genesis_hash []u8) ?types.Transaction {
	// Decode from address
	from_addr := types.decode_address(from)?

	// Decode to address
	to_addr := types.decode_address(to)?

	// Decode the close_remainder_to address, if present
	close_remainder_to_addr := if close_remainder_to != '' {
		types.decode_address(close_remainder_to)?
	} else {
		types.new_address()
	}

	// Decode GenesisHash
	if genesis_hash.len == 0 {
		return error('payment transaction must contain a genesisHash')
	}

	// var gh types.Digest
	// copy(gh[:], genesis_hash)
	gh := genesis_hash.clone()

	// Build the transaction
	mut tx := types.Transaction{
		type_: types.payment_tx,
		Header: types.Header{
			sender:       from_addr,
			fee:          types.MicroAlgos(fee),
			first_valid:  types.Round(first_round),
			last_valid:   types.Round(last_round),
			note:         note,
			genesis_id:   genesis_id,
			genesis_hash: gh,
		},
		PaymentTxnFields: types.PaymentTxnFields{
			receiver:           to_addr,
			amount:             types.MicroAlgos(amount),
			close_remainder_to: close_remainder_to_addr,
		},
	}

	// Update fee
	e_size := estimate_size(tx)?
	tx.fee = types.MicroAlgos(e_size * fee)

	if tx.fee < min_txn_fee {
		tx.fee = min_txn_fee
	}

	return tx
}

// MakePaymentTxnWithFlatFee constructs a payment transaction using the passed parameters.
// `from` and `to` addresses should be checksummed, human-readable addresses
// fee is a flat fee
// Deprecated: next major version will use a Params object, see package future
pub fn make_payment_txn_with_flat_fee(from string, to string, fee u64, amount u64, first_round u64, last_round u64, note []u8, close_remainder_to string, genesis_id string, genesis_hash []u8) ?types.Transaction {
	mut tx := make_payment_txn(from, to, fee, amount, first_round, last_round, note, close_remainder_to, genesis_id, genesis_hash)?
	tx.fee = types.MicroAlgos(fee)

	if tx.fee < min_txn_fee {
		tx.fee = min_txn_fee
	}

	return tx
}

// // MakeKeyRegTxn constructs a keyreg transaction using the passed parameters.
// // - account is a checksummed, human-readable address for which we register the given participation key.
// // - fee is fee per byte as received from algod SuggestedFee API call.
// // - firstRound is the first round this txn is valid (txn semantics unrelated to key registration)
// // - lastRound is the last round this txn is valid
// // - note is a byte array
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // KeyReg parameters:
// // - votePK is a base64-encoded string corresponding to the root participation public key
// // - selectionKey is a base64-encoded string corresponding to the vrf public key
// // - voteFirst is the first round this participation key is valid
// // - voteLast is the last round this participation key is valid
// // - voteKeyDilution is the dilution for the 2-level participation key
// // Deprecated: next major version will use a Params object, see package future
// func MakeKeyRegTxn(account string, feePerByte, firstRound, lastRound u64, note []byte, genesisID string, genesisHash string,
// 	voteKey, selectionKey string, voteFirst, voteLast, voteKeyDilution u64) (types.Transaction, error) {
// 	// Decode account address
// 	accountAddr, err := types.decode_address(account)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	ghBytes, err := byte32FromBase64(genesisHash)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	votePKBytes, err := byte32FromBase64(voteKey)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	selectionPKBytes, err := byte32FromBase64(selectionKey)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	tx := types.Transaction{
// 		Type: types.KeyRegistrationTx,
// 		Header: types.Header{
// 			Sender:      accountAddr,
// 			Fee:         types.MicroAlgos(feePerByte),
// 			FirstValid:  types.Round(firstRound),
// 			LastValid:   types.Round(lastRound),
// 			Note:        note,
// 			GenesisHash: types.Digest(ghBytes),
// 			GenesisID:   genesisID,
// 		},
// 		KeyregTxnFields: types.KeyregTxnFields{
// 			VotePK:          types.VotePK(votePKBytes),
// 			SelectionPK:     types.VRFPK(selectionPKBytes),
// 			VoteFirst:       types.Round(voteFirst),
// 			VoteLast:        types.Round(voteLast),
// 			VoteKeyDilution: voteKeyDilution,
// 		},
// 	}

// 	// Update fee
// 	eSize, err := estimate_size(tx)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}
// 	tx.Fee = types.MicroAlgos(eSize * feePerByte)

// 	if tx.Fee < min_txn_fee {
// 		tx.Fee = min_txn_fee
// 	}

// 	return tx, nil
// }

// // MakeKeyRegTxnWithFlatFee constructs a keyreg transaction using the passed parameters.
// // - account is a checksummed, human-readable address for which we register the given participation key.
// // - fee is a flat fee
// // - firstRound is the first round this txn is valid (txn semantics unrelated to key registration)
// // - lastRound is the last round this txn is valid
// // - note is a byte array
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // KeyReg parameters:
// // - votePK is a base64-encoded string corresponding to the root participation public key
// // - selectionKey is a base64-encoded string corresponding to the vrf public key
// // - voteFirst is the first round this participation key is valid
// // - voteLast is the last round this participation key is valid
// // - voteKeyDilution is the dilution for the 2-level participation key
// // Deprecated: next major version will use a Params object, see package future
// func MakeKeyRegTxnWithFlatFee(account string, fee, firstRound, lastRound u64, note []byte, genesisID string, genesisHash string,
// 	voteKey, selectionKey string, voteFirst, voteLast, voteKeyDilution u64) (types.Transaction, error) {
// 	tx, err := MakeKeyRegTxn(account, fee, firstRound, lastRound, note, genesisID, genesisHash, voteKey, selectionKey, voteFirst, voteLast, voteKeyDilution)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	tx.Fee = types.MicroAlgos(fee)

// 	if tx.Fee < min_txn_fee {
// 		tx.Fee = min_txn_fee
// 	}

// 	return tx, nil
// }

// // MakeAssetCreateTxn constructs an asset creation transaction using the passed parameters.
// // - account is a checksummed, human-readable address which will send the transaction.
// // - fee is fee per byte as received from algod SuggestedFee API call.
// // - firstRound is the first round this txn is valid (txn semantics unrelated to the asset)
// // - lastRound is the last round this txn is valid
// // - note is a byte array
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // Asset creation parameters:
// // - see asset.go
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetCreateTxn(account string, feePerByte, firstRound, lastRound u64, note []byte, genesisID, genesisHash string,
// 	total u64, decimals uint32, defaultFrozen bool, manager, reserve, freeze, clawback string,
// 	unitName, assetName, url, metadataHash string) (types.Transaction, error) {
// 	var tx types.Transaction
// 	var err error

// 	if decimals > types.AssetMaxNumberOfDecimals {
// 		return tx, fmt.Errorf('cannot create an asset with number of decimals %d (more than maximum %d)', decimals, types.AssetMaxNumberOfDecimals)
// 	}

// 	tx.Type = types.AssetConfigTx
// 	tx.AssetParams = types.AssetParams{
// 		Total:         total,
// 		Decimals:      decimals,
// 		DefaultFrozen: defaultFrozen,
// 		UnitName:      unitName,
// 		AssetName:     assetName,
// 		URL:           url,
// 	}

// 	if manager != '' {
// 		tx.AssetParams.Manager, err = types.decode_address(manager)
// 		if err != nil {
// 			return tx, err
// 		}
// 	}
// 	if reserve != '' {
// 		tx.AssetParams.Reserve, err = types.decode_address(reserve)
// 		if err != nil {
// 			return tx, err
// 		}
// 	}
// 	if freeze != '' {
// 		tx.AssetParams.Freeze, err = types.decode_address(freeze)
// 		if err != nil {
// 			return tx, err
// 		}
// 	}
// 	if clawback != '' {
// 		tx.AssetParams.Clawback, err = types.decode_address(clawback)
// 		if err != nil {
// 			return tx, err
// 		}
// 	}

// 	if len(assetName) > types.AssetNameMaxLen {
// 		return tx, fmt.Errorf('asset name too long: %d > %d', len(assetName), types.AssetNameMaxLen)
// 	}
// 	tx.AssetParams.AssetName = assetName

// 	if len(url) > types.AssetURLMaxLen {
// 		return tx, fmt.Errorf('asset url too long: %d > %d', len(url), types.AssetURLMaxLen)
// 	}
// 	tx.AssetParams.URL = url

// 	if len(unitName) > types.AssetUnitNameMaxLen {
// 		return tx, fmt.Errorf('asset unit name too long: %d > %d', len(unitName), types.AssetUnitNameMaxLen)
// 	}
// 	tx.AssetParams.UnitName = unitName

// 	if len(metadataHash) > types.AssetMetadataHashLen {
// 		return tx, fmt.Errorf('asset metadata hash '%s' too long: %d > %d)', metadataHash, len(metadataHash), types.AssetMetadataHashLen)
// 	}
// 	copy(tx.AssetParams.MetadataHash[:], []byte(metadataHash))

// 	// Fill in header
// 	accountAddr, err := types.decode_address(account)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}
// 	ghBytes, err := byte32FromBase64(genesisHash)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}
// 	tx.Header = types.Header{
// 		Sender:      accountAddr,
// 		Fee:         types.MicroAlgos(feePerByte),
// 		FirstValid:  types.Round(firstRound),
// 		LastValid:   types.Round(lastRound),
// 		GenesisHash: types.Digest(ghBytes),
// 		GenesisID:   genesisID,
// 		Note:        note,
// 	}

// 	// Update fee
// 	eSize, err := estimate_size(tx)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}
// 	tx.Fee = types.MicroAlgos(eSize * feePerByte)

// 	if tx.Fee < min_txn_fee {
// 		tx.Fee = min_txn_fee
// 	}

// 	return tx, nil
// }

// // MakeAssetConfigTxn creates a tx template for changing the
// // key configuration of an existing asset.
// // Important notes -
// // 	* Every asset config transaction is a fresh one. No parameters will be inherited from the current config.
// // 	* Once an address is set to to the empty string, IT CAN NEVER BE CHANGED AGAIN. For example, if you want to keep
// //    The current manager, you must specify its address again.
// //	Parameters -
// // - account is a checksummed, human-readable address that will send the transaction
// // - feePerByte  is a fee per byte
// // - firstRound is the first round this txn is valid (txn semantics unrelated to asset config)
// // - lastRound is the last round this txn is valid
// // - note is an arbitrary byte array
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // - index is the asset index id
// // - for newManager, newReserve, newFreeze, newClawback see asset.go
// // - strictEmptyAddressChecking: if true, disallow empty admin accounts from being set (preventing accidental disable of admin features)
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetConfigTxn(account string, feePerByte, firstRound, lastRound u64, note []byte, genesisID, genesisHash string,
// 	index u64, newManager, newReserve, newFreeze, newClawback string, strictEmptyAddressChecking bool) (types.Transaction, error) {
// 	var tx types.Transaction

// 	if strictEmptyAddressChecking && (newManager == '' || newReserve == '' || newFreeze == '' || newClawback == '') {
// 		return tx, fmt.Errorf('strict empty address checking requested but empty address supplied to one or more manager addresses')
// 	}

// 	tx.Type = types.AssetConfigTx

// 	accountAddr, err := types.decode_address(account)
// 	if err != nil {
// 		return tx, err
// 	}

// 	ghBytes, err := byte32FromBase64(genesisHash)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	tx.Header = types.Header{
// 		Sender:      accountAddr,
// 		Fee:         types.MicroAlgos(feePerByte),
// 		FirstValid:  types.Round(firstRound),
// 		LastValid:   types.Round(lastRound),
// 		GenesisHash: ghBytes,
// 		GenesisID:   genesisID,
// 		Note:        note,
// 	}

// 	tx.ConfigAsset = types.AssetIndex(index)

// 	if newManager != '' {
// 		tx.Type = types.AssetConfigTx
// 		tx.AssetParams.Manager, err = types.decode_address(newManager)
// 		if err != nil {
// 			return tx, err
// 		}
// 	}

// 	if newReserve != '' {
// 		tx.AssetParams.Reserve, err = types.decode_address(newReserve)
// 		if err != nil {
// 			return tx, err
// 		}
// 	}

// 	if newFreeze != '' {
// 		tx.AssetParams.Freeze, err = types.decode_address(newFreeze)
// 		if err != nil {
// 			return tx, err
// 		}
// 	}

// 	if newClawback != '' {
// 		tx.AssetParams.Clawback, err = types.decode_address(newClawback)
// 		if err != nil {
// 			return tx, err
// 		}
// 	}

// 	// Update fee
// 	eSize, err := estimate_size(tx)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}
// 	tx.Fee = types.MicroAlgos(eSize * feePerByte)

// 	if tx.Fee < min_txn_fee {
// 		tx.Fee = min_txn_fee
// 	}

// 	return tx, nil
// }

// // transferAssetBuilder is a helper that builds asset transfer transactions:
// // either a normal asset transfer, or an asset revocation
// // Deprecated: next major version will use a Params object, see package future
// func transferAssetBuilder(account, recipient, closeAssetsTo, revocationTarget string, amount, feePerByte,
// 	firstRound, lastRound u64, note []byte, genesisID, genesisHash string, index u64) (types.Transaction, error) {
// 	var tx types.Transaction
// 	tx.Type = types.AssetTransferTx

// 	accountAddr, err := types.decode_address(account)
// 	if err != nil {
// 		return tx, err
// 	}

// 	ghBytes, err := byte32FromBase64(genesisHash)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	tx.Header = types.Header{
// 		Sender:      accountAddr,
// 		Fee:         types.MicroAlgos(feePerByte),
// 		FirstValid:  types.Round(firstRound),
// 		LastValid:   types.Round(lastRound),
// 		GenesisHash: types.Digest(ghBytes),
// 		GenesisID:   genesisID,
// 		Note:        note,
// 	}

// 	tx.XferAsset = types.AssetIndex(index)

// 	recipientAddr, err := types.decode_address(recipient)
// 	if err != nil {
// 		return tx, err
// 	}
// 	tx.AssetReceiver = recipientAddr

// 	if closeAssetsTo != '' {
// 		closeToAddr, err := types.decode_address(closeAssetsTo)
// 		if err != nil {
// 			return tx, err
// 		}
// 		tx.AssetCloseTo = closeToAddr
// 	}

// 	if revocationTarget != '' {
// 		revokedAddr, err := types.decode_address(revocationTarget)
// 		if err != nil {
// 			return tx, err
// 		}
// 		tx.AssetSender = revokedAddr
// 	}

// 	tx.AssetAmount = amount

// 	// Update fee
// 	eSize, err := estimate_size(tx)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}
// 	tx.Fee = types.MicroAlgos(eSize * feePerByte)

// 	if tx.Fee < min_txn_fee {
// 		tx.Fee = min_txn_fee
// 	}

// 	return tx, nil
// }

// // MakeAssetTransferTxn creates a tx for sending some asset from an asset holder to another user
// // the recipient address must have previously issued an asset acceptance transaction for this asset
// // - account is a checksummed, human-readable address that will send the transaction and assets
// // - recipient is a checksummed, human-readable address what will receive the assets
// // - closeAssetsTo is a checksummed, human-readable address that behaves as a close-to address for the asset transaction; the remaining assets not sent to recipient will be sent to closeAssetsTo. Leave blank for no close-to behavior.
// // - amount is the number of assets to send
// // - feePerByte is a fee per byte
// // - firstRound is the first round this txn is valid (txn semantics unrelated to asset management)
// // - lastRound is the last round this txn is valid
// // - note is an arbitrary byte array
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // - index is the asset index
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetTransferTxn(account, recipient, closeAssetsTo string, amount, feePerByte, firstRound, lastRound u64, note []byte,
// 	genesisID, genesisHash string, index u64) (types.Transaction, error) {
// 	revocationTarget := '' // no asset revocation, this is normal asset transfer
// 	return transferAssetBuilder(account, recipient, closeAssetsTo, revocationTarget, amount, feePerByte, firstRound, lastRound,
// 		note, genesisID, genesisHash, index)
// }

// // MakeAssetAcceptanceTxn creates a tx for marking an account as willing to accept the given asset
// // - account is a checksummed, human-readable address that will send the transaction and begin accepting the asset
// // - feePerByte is a fee per byte
// // - firstRound is the first round this txn is valid (txn semantics unrelated to asset management)
// // - lastRound is the last round this txn is valid
// // - note is an arbitrary byte array
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // - index is the asset index
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetAcceptanceTxn(account string, feePerByte, firstRound, lastRound u64, note []byte,
// 	genesisID, genesisHash string, index u64) (types.Transaction, error) {
// 	return MakeAssetTransferTxn(account, account, '', 0,
// 		feePerByte, firstRound, lastRound, note, genesisID, genesisHash, index)
// }

// // MakeAssetRevocationTxn creates a tx for revoking an asset from an account and sending it to another
// // - account is a checksummed, human-readable address; it must be the revocation manager / clawback address from the asset's parameters
// // - target is a checksummed, human-readable address; it is the account whose assets will be revoked
// // - recipient is a checksummed, human-readable address; it will receive the revoked assets
// // - feePerByte is a fee per byte
// // - firstRound is the first round this txn is valid (txn semantics unrelated to asset management)
// // - lastRound is the last round this txn is valid
// // - note is an arbitrary byte array
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // - index is the asset index
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetRevocationTxn(account, target, recipient string, amount, feePerByte, firstRound, lastRound u64, note []byte,
// 	genesisID, genesisHash string, index u64) (types.Transaction, error) {
// 	closeAssetsTo := '' // no close-out, this is an asset revocation
// 	return transferAssetBuilder(account, recipient, closeAssetsTo, target, amount, feePerByte, firstRound, lastRound,
// 		note, genesisID, genesisHash, index)
// }

// // MakeAssetDestroyTxn creates a tx template for destroying an asset, removing it from the record.
// // All outstanding asset amount must be held by the creator, and this transaction must be issued by the asset manager.
// // - account is a checksummed, human-readable address that will send the transaction; it also must be the asset manager
// // - fee is a fee per byte
// // - firstRound is the first round this txn is valid (txn semantics unrelated to asset management)
// // - lastRound is the last round this txn is valid
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // - index is the asset index
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetDestroyTxn(account string, feePerByte, firstRound, lastRound u64, note []byte, genesisID, genesisHash string,
// 	index u64) (types.Transaction, error) {
// 	// an asset destroy transaction is just a configuration transaction with AssetParams zeroed
// 	tx, err := MakeAssetConfigTxn(account, feePerByte, firstRound, lastRound, note, genesisID, genesisHash,
// 		index, '', '', '', '', false)

// 	return tx, err
// }

// // MakeAssetFreezeTxn constructs a transaction that freezes or unfreezes an account's asset holdings
// // It must be issued by the freeze address for the asset
// // - account is a checksummed, human-readable address which will send the transaction.
// // - fee is fee per byte as received from algod SuggestedFee API call.
// // - firstRound is the first round this txn is valid (txn semantics unrelated to the asset)
// // - lastRound is the last round this txn is valid
// // - note is an optional arbitrary byte array
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // - assetIndex is the index for tracking the asset
// // - target is the account to be frozen or unfrozen
// // - newFreezeSetting is the new state of the target account
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetFreezeTxn(account string, fee, firstRound, lastRound u64, note []byte, genesisID, genesisHash string,
// 	assetIndex u64, target string, newFreezeSetting bool) (types.Transaction, error) {
// 	var tx types.Transaction

// 	tx.Type = types.AssetFreezeTx

// 	accountAddr, err := types.decode_address(account)
// 	if err != nil {
// 		return tx, err
// 	}

// 	ghBytes, err := byte32FromBase64(genesisHash)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	tx.Header = types.Header{
// 		Sender:      accountAddr,
// 		Fee:         types.MicroAlgos(fee),
// 		FirstValid:  types.Round(firstRound),
// 		LastValid:   types.Round(lastRound),
// 		GenesisHash: types.Digest(ghBytes),
// 		GenesisID:   genesisID,
// 		Note:        note,
// 	}

// 	tx.FreezeAsset = types.AssetIndex(assetIndex)

// 	tx.FreezeAccount, err = types.decode_address(target)
// 	if err != nil {
// 		return tx, err
// 	}

// 	tx.AssetFrozen = newFreezeSetting
// 	// Update fee
// 	eSize, err := estimate_size(tx)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}
// 	tx.Fee = types.MicroAlgos(eSize * fee)

// 	if tx.Fee < min_txn_fee {
// 		tx.Fee = min_txn_fee
// 	}

// 	return tx, nil
// }

// // MakeAssetCreateTxnWithFlatFee constructs an asset creation transaction using the passed parameters.
// // - account is a checksummed, human-readable address which will send the transaction.
// // - fee is fee per byte as received from algod SuggestedFee API call.
// // - firstRound is the first round this txn is valid (txn semantics unrelated to the asset)
// // - lastRound is the last round this txn is valid
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // Asset creation parameters:
// // - see asset.go
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetCreateTxnWithFlatFee(account string, fee, firstRound, lastRound u64, note []byte, genesisID, genesisHash string,
// 	total u64, decimals uint32, defaultFrozen bool, manager, reserve, freeze, clawback, unitName, assetName, url, metadataHash string) (types.Transaction, error) {
// 	tx, err := MakeAssetCreateTxn(account, fee, firstRound, lastRound, note, genesisID, genesisHash, total, decimals, defaultFrozen, manager, reserve, freeze, clawback, unitName, assetName, url, metadataHash)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	tx.Fee = types.MicroAlgos(fee)

// 	if tx.Fee < min_txn_fee {
// 		tx.Fee = min_txn_fee
// 	}

// 	return tx, nil
// }

// // MakeAssetConfigTxnWithFlatFee creates a tx template for changing the
// // keys for an asset. An empty string means a zero key (which
// // cannot be changed after becoming zero); to keep a key
// // unchanged, you must specify that key.
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetConfigTxnWithFlatFee(account string, fee, firstRound, lastRound u64, note []byte, genesisID, genesisHash string,
// 	index u64, newManager, newReserve, newFreeze, newClawback string, strictEmptyAddressChecking bool) (types.Transaction, error) {
// 	tx, err := MakeAssetConfigTxn(account, fee, firstRound, lastRound, note, genesisID, genesisHash,
// 		index, newManager, newReserve, newFreeze, newClawback, strictEmptyAddressChecking)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	tx.Fee = types.MicroAlgos(fee)

// 	if tx.Fee < min_txn_fee {
// 		tx.Fee = min_txn_fee
// 	}
// 	return tx, nil
// }

// // MakeAssetTransferTxnWithFlatFee creates a tx for sending some asset from an asset holder to another user
// // the recipient address must have previously issued an asset acceptance transaction for this asset
// // - account is a checksummed, human-readable address that will send the transaction and assets
// // - recipient is a checksummed, human-readable address what will receive the assets
// // - closeAssetsTo is a checksummed, human-readable address that behaves as a close-to address for the asset transaction; the remaining assets not sent to recipient will be sent to closeAssetsTo. Leave blank for no close-to behavior.
// // - amount is the number of assets to send
// // - fee is a flat fee
// // - firstRound is the first round this txn is valid (txn semantics unrelated to asset management)
// // - lastRound is the last round this txn is valid
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // - index is the asset index
// func MakeAssetTransferTxnWithFlatFee(account, recipient, closeAssetsTo string, amount, fee, firstRound, lastRound u64, note []byte,
// 	genesisID, genesisHash string, index u64) (types.Transaction, error) {
// 	tx, err := MakeAssetTransferTxn(account, recipient, closeAssetsTo, amount,
// 		fee, firstRound, lastRound, note, genesisID, genesisHash, index)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	tx.Fee = types.MicroAlgos(fee)

// 	if tx.Fee < min_txn_fee {
// 		tx.Fee = min_txn_fee
// 	}
// 	return tx, nil
// }

// // MakeAssetAcceptanceTxnWithFlatFee creates a tx for marking an account as willing to accept an asset
// // - account is a checksummed, human-readable address that will send the transaction and begin accepting the asset
// // - fee is a flat fee
// // - firstRound is the first round this txn is valid (txn semantics unrelated to asset management)
// // - lastRound is the last round this txn is valid
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // - index is the asset index
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetAcceptanceTxnWithFlatFee(account string, fee, firstRound, lastRound u64, note []byte,
// 	genesisID, genesisHash string, index u64) (types.Transaction, error) {
// 	tx, err := MakeAssetTransferTxnWithFlatFee(account, account, '', 0,
// 		fee, firstRound, lastRound, note, genesisID, genesisHash, index)
// 	return tx, err
// }

// // MakeAssetRevocationTxnWithFlatFee creates a tx for revoking an asset from an account and sending it to another
// // - account is a checksummed, human-readable address; it must be the revocation manager / clawback address from the asset's parameters
// // - target is a checksummed, human-readable address; it is the account whose assets will be revoked
// // - recipient is a checksummed, human-readable address; it will receive the revoked assets
// // - fee is a flat fee
// // - firstRound is the first round this txn is valid (txn semantics unrelated to asset management)
// // - lastRound is the last round this txn is valid
// // - note is an arbitrary byte array
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // - index is the asset index
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetRevocationTxnWithFlatFee(account, target, recipient string, amount, fee, firstRound, lastRound u64, note []byte,
// 	genesisID, genesisHash, creator string, index u64) (types.Transaction, error) {
// 	tx, err := MakeAssetRevocationTxn(account, target, recipient, amount, fee, firstRound, lastRound,
// 		note, genesisID, genesisHash, index)

// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	tx.Fee = types.MicroAlgos(fee)

// 	if tx.Fee < min_txn_fee {
// 		tx.Fee = min_txn_fee
// 	}
// 	return tx, nil
// }

// // MakeAssetDestroyTxnWithFlatFee creates a tx template for destroying an asset, removing it from the record.
// // All outstanding asset amount must be held by the creator, and this transaction must be issued by the asset manager.
// // - account is a checksummed, human-readable address that will send the transaction; it also must be the asset manager
// // - fee is a flat fee
// // - firstRound is the first round this txn is valid (txn semantics unrelated to asset management)
// // - lastRound is the last round this txn is valid
// // - genesis id corresponds to the id of the network
// // - genesis hash corresponds to the base64-encoded hash of the genesis of the network
// // - index is the asset index
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetDestroyTxnWithFlatFee(account string, fee, firstRound, lastRound u64, note []byte, genesisID, genesisHash string,
// 	creator string, index u64) (types.Transaction, error) {
// 	tx, err := MakeAssetConfigTxnWithFlatFee(account, fee, firstRound, lastRound, note, genesisID, genesisHash,
// 		index, '', '', '', '', false)
// 	return tx, err
// }

// // MakeAssetFreezeTxnWithFlatFee is as MakeAssetFreezeTxn, but taking a flat fee rather than a fee per byte.
// // Deprecated: next major version will use a Params object, see package future
// func MakeAssetFreezeTxnWithFlatFee(account string, fee, firstRound, lastRound u64, note []byte, genesisID, genesisHash string,
// 	creator string, assetIndex u64, target string, newFreezeSetting bool) (types.Transaction, error) {
// 	tx, err := MakeAssetFreezeTxn(account, fee, firstRound, lastRound, note, genesisID, genesisHash,
// 		assetIndex, target, newFreezeSetting)
// 	if err != nil {
// 		return types.Transaction{}, err
// 	}

// 	tx.Fee = types.MicroAlgos(fee)

// 	if tx.Fee < min_txn_fee {
// 		tx.Fee = min_txn_fee
// 	}
// 	return tx, nil
// }

// // AssignGroupID computes and return list of transactions with Group field set.
// // - txns is a list of transactions to process
// // - account specifies a sender field of transaction to return. Set to empty string to return all of them
// func AssignGroupID(txns []types.Transaction, account string) (result []types.Transaction, err error) {
// 	gid, err := crypto.ComputeGroupID(txns)
// 	if err != nil {
// 		return
// 	}
// 	var decoded types.Address
// 	if account != '' {
// 		decoded, err = types.decode_address(account)
// 		if err != nil {
// 			return
// 		}
// 	}
// 	for _, tx := range txns {
// 		if account == '' || bytes.Compare(tx.Sender[:], decoded[:]) == 0 {
// 			tx.Group = gid
// 			result = append(result, tx)
// 		}
// 	}
// 	return result, nil
// }

// EstimateSize returns the estimated length of the encoded transaction
fn estimate_size(txn types.Transaction) ?u64 {
	return u64(msgpack.encode(txn).len) + num_of_additional_bytes_after_signing
}

// // byte32FromBase64 decodes the input base64 string and outputs a
// // 32 byte array, erroring if the input is the wrong length.
// func byte32FromBase64(in string) (out [32]byte, err error) {
// 	slice, err := base64.StdEncoding.DecodeString(in)
// 	if err != nil {
// 		return
// 	}
// 	if len(slice) != 32 {
// 		return out, fmt.Errorf('Input is not 32 bytes')
// 	}
// 	copy(out[:], slice)
// 	return
// }
