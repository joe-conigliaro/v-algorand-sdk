module types

// import math
// import encoding.base64
// import encoding.msgpack
// import crypto.ed25519

// TxType identifies the type of the transaction
pub type TxType = string

pub const (
	// payment_tx is the TxType for payment transactions
	payment_tx          = TxType('pay')
	// key_registration_tx is the TxType for key registration transactions
	key_registration_tx = TxType('keyreg')
	// asset_config_tx creates, re-configures, or destroys an asset
	asset_config_tx     = TxType('acfg')
	// asset_transfer_tx transfers assets between accounts (optionally closing)
	asset_transfer_tx   = TxType('axfer')
	// asset_freeze_tx changes the freeze status of an asset
	asset_freeze_tx     = TxType('afrz')
	// application_call_tx allows creating, deleting, and interacting with an application
	application_call_tx = TxType('appl')
)

pub const (
	master_derivation_key_len_bytes = 32

	// max_tx_group_size is max number of transactions in a single group
	max_tx_group_size               = 16
	// logic_sig_max_size is a max TEAL program size (with args)
	logic_sig_max_size              = 1000
	// logic_sig_max_cost is a max execution const of a TEAL program
	logic_sig_max_cost              = 20000
	// key_store_root_size is the size, in bytes, of keyreg verifier
	key_store_root_size             = 64
)

// MicroAlgos are the base unit of currency in Algorand
pub type MicroAlgos = u64

// // Round represents a round of the Algorand consensus protocol
pub type Round = u64

// VotePK is the participation public key used in key registration transactions
// type VotePK = [ed25519.public_key_size]u8
type VotePK = [32]u8

// VRFPK is the VRF public key used in key registration transactions
// type VRFPK = [ed25519.public_key_size]u8
type VRFPK = [32]u8

// MasterDerivationKey is the secret key used to derive keys in wallets
// type MasterDerivationKey = [master_derivation_key_len_bytes]u8
type MasterDerivationKey = []u8

pub const (
	zero_digest = new_digest()
)

// Digest is a SHA512_256 hash
// type Digest = [hash_len_bytes]u8
pub type Digest = []u8

pub fn (d Digest) bytes() []u8 {
	return d
}

pub fn new_digest() Digest {
	return []u8{}
}

// // MerkleVerifier is a state proof
type MerkleVerifier = [key_store_root_size]u8

const micro_algo_conversion_factor = 1e6

// // ToAlgos converts amount in microAlgos to Algos
// func (microalgos MicroAlgos) ToAlgos() float64 {
// 	return float64(microalgos) / micro_algo_conversion_factor
// }

// // ToMicroAlgos converts amount in Algos to microAlgos
// func ToMicroAlgos(algos float64) MicroAlgos {
// 	return MicroAlgos(math.Round(algos * micro_algo_conversion_factor))
// }

// func (signedTxn *SignedTxn) FromBase64String(b64string string) error {
// 	txnBytes, err := base64.StdEncoding.DecodeString(b64string)
// 	if err != nil {
// 		return err
// 	}
// 	err = msgpack.Decode(txnBytes, &signedTxn)
// 	if err != nil {
// 		return err
// 	}
// 	return nil
// }

// func (block *Block) FromBase64String(b64string string) error {
// 	txnBytes, err := base64.StdEncoding.DecodeString(b64string)
// 	if err != nil {
// 		return err
// 	}
// 	err = msgpack.Decode(txnBytes, &block)
// 	if err != nil {
// 		return err
// 	}
// 	return nil
// }
