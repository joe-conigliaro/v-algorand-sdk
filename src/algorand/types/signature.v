module types

import crypto.ed25519

pub const(
	// zero_signature = new_signature()
	zero_signature = []u8{}
)
// Signature is an ed25519 signature
// type Signature = [ed25519.signature_size]u8 // TODO: this seems like it should work fine also
// pub type Signature = [64]u8
pub type Signature = []u8

pub fn (s Signature) to_u8_array() []u8 {
	return s
}

// pub fn (s Signature) str() string {
// 	return s.hex()
// }

pub fn new_signature() Signature {
	return []u8{}
}

// MultisigSubsig contains a single public key and, optionally, a signature
[codec:',omitempty,omitemptyarray']
pub struct MultisigSubsig {
pub mut:
	key ed25519.PublicKey [codec:'pk']
	// sig Signature         [codec:'s']
	sig []u8         		 [codec:'s']
}

// MultisigSig holds multiple Subsigs, as well as threshold and version info
 [codec: ',omitempty,omitemptyarray']
pub struct MultisigSig {
pub mut:
	version   u8               [codec:'v']
	threshold u8               [codec:'thr']
	subsigs   []MultisigSubsig [codec:'subsig']
}

// Blank returns true iff the msig is empty. We need this instead of just
// comparing with == MultisigSig{}, because Subsigs is a slice.
pub fn (msig MultisigSig) blank() bool {
	if msig.version != 0 {
		return false
	}
	if msig.threshold != 0 {
		return false
	}
	// if msig.subsigs != nil {
	// TODO: (array.len == 0) != nil slice
	if msig.subsigs.len != 0 {
		return false
	}
	return true
}

// LogicSig contains logic for validating a transaction.
// LogicSig is signed by an account, allowing delegation of operations.
// OR
// LogicSig defines a contract account.
[codec: ',omitempty,omitemptyarray']
pub struct LogicSig {
pub mut:
	// Logic signed by Sig or Msig
	// OR hashed to be the Address of an account.
	logic []u8 [codec: 'l']

	// The signature of the account that has delegated to this LogicSig, if any
	// sig Signature [codec: 'sig']
	sig []u8 [codec: 'sig']

	// The signature of the multisig account that has delegated to this LogicSig, if any
	msig MultisigSig [codec: 'msig']

	// Args are not signed, but checked by Logic
	args [][]u8 [codec:'arg']
}

// Blank returns true iff the lsig is empty. We need this instead of just
// comparing with == LogicSig{}, because it contains slices.
fn (lsig LogicSig) blank() bool {
	// if lsig.args != nil {
	// TODO: (array.len == 0) != nil slice
	if lsig.args.len != 0 {
		return false
	}
	if lsig.logic.len != 0 {
		return false
	}
	if !lsig.msig.blank() {
		return false
	}
	// if lsig.sig != (Signature{}) {
	if lsig.sig != types.zero_signature {
		return false
	}
	return true
}
