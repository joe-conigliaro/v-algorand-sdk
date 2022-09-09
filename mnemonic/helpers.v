module mnemonic

import crypto.ed25519
import algorand.types

// from_private_key is a helper that converts an ed25519 private key to a
// human-readable mnemonic
pub fn from_private_key(sk ed25519.PrivateKey) ?string {
	seed := sk.seed()
	return from_key(seed)
}

// to_private_key is a helper that converts a mnemonic directly to an ed25519
// private key
pub fn to_private_key(mnemonic string) ?ed25519.PrivateKey {
	seed_bytes := to_key(mnemonic)?
	return ed25519.new_key_from_seed(seed_bytes)
}

// from_master_derivation_key is a helper that converts an MDK to a human-readable
// mnemonic
pub fn from_master_derivation_key(mdk types.MasterDerivationKey) ?string {
	return from_key(mdk)
}

// to_master_derivation_key is a helper that converts a mnemonic directly to a
// master derivation key
pub fn to_master_derivation_key(mnemonic string) ?types.MasterDerivationKey {
	mdk_bytes := to_key(mnemonic)?
	if mdk_bytes.len != types.master_derivation_key_len_bytes {
		panic("recovered mdk is wrong length")
	}
	// copy(mdk[:], mdk_bytes)
	return types.MasterDerivationKey(mdk_bytes.clone())
}
