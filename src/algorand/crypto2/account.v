module crypto2

import crypto.sha512
import crypto.ed25519
import types

// prefix for multisig transaction signing
const msig_add_prefix = 'MultisigAddr'

// Account holds both the public and private information associated with an
// Algorand address
struct Account {
pub mut:
	public_key  ed25519.PublicKey
	private_key ed25519.PrivateKey
	address     types.Address
}

fn init() {
	// addr_len := len(types.Address{})
	addr_len := types.hash_len_bytes
	pk_len := ed25519.public_key_size
	if addr_len != pk_len {
		panic('address and public key are different sizes')
	}
}

// generate_account generates a random Account
pub fn generate_account() Account {
	// Generate an ed25519 keypair. This should never fail
	pk, sk := ed25519.generate_key() or {
		panic(err)
	}

	// Convert the public key to an address
	// mut a := types.Address{}
	// n := copy(a[:], pk)
	a := types.Address(pk.clone())
	// if n != ed25519.public_key_size {
	if a.len != ed25519.public_key_size {
		panic('generated public key is the wrong size')
	}

	// Build the account
	return Account{
		public_key: pk,
		private_key: sk,
		address: a
	}
}

// account_from_private_key derives the remaining Account fields from only a
// private key. The argument sk must have a length equal to
// ed25519.private_key_size.
fn account_from_private_key(sk ed25519.PrivateKey) ?Account {
	if sk.len != ed25519.private_key_size {
		return errInvalidPrivateKey
	}

	mut account := Account{}
	// copy sk
	// account.private_key = make(ed25519.PrivateKey, len(sk))
	// copy(account.private_key, sk)
	account.private_key = sk.clone()
	account.public_key = sk.public_key()
	if account.public_key.len != ed25519.public_key_size {
		return error('generated public key is the wrong size')
	}

	// copy(account.address[:], account.public_key)
	account.address = account.public_key.clone()

	return account
}

/* Multisig Support */

// MultisigAccount is a convenience type for holding multisig preimage data
struct MultisigAccount {
mut:
	// Version is the version of this multisig
	version u8
	// Threshold is how many signatures are needed to fully sign as this address
	threshold u8
	// Pks is an ordered list of public keys that could potentially sign a message
	pks []ed25519.PublicKey
}

// multisig_account_with_params creates a MultisigAccount with the given parameters
fn multisig_account_with_params(version u8, threshold u8, addrs []types.Address) ?MultisigAccount {
	mut ma := MultisigAccount{}
	ma.version = version
	ma.threshold = threshold
	// ma.pks = make([]ed25519.PublicKey{}, len(addrs))
	for i := 0; i < addrs.len; i++ {
		// ma.pks[i] = addrs[i][:]
		ma.pks[i] = ed25519.PublicKey(addrs[i])
	}
	ma.validate()?
	return ma
}

// multisig_account_from_sig is a convenience method that creates an account
// from a sig in a signed tx. Useful for getting addresses from signed msig txs, etc.
fn multisig_account_from_sig(sig types.MultisigSig) ?MultisigAccount {
	mut ma := MultisigAccount{}
	ma.version = sig.version
	ma.threshold = sig.threshold
	// ma.pks = make([]ed25519.PublicKey{}, len(sig.subsigs))
	for i := 0; i < sig.subsigs.len; i++ {
		// c := make([]byte, len(sig.subsigs[i].key))
		// copy(c, sig.subsigs[i].key)
		// ma.pks[i] = c
		ma.pks[i] = sig.subsigs[i].key.clone()
	}
	ma.validate()?
	return ma
}

// address takes this multisig preimage data, and generates the corresponding identifying
// address, committing to the exact group, version, and public keys that it requires to sign.
// Hash('MultisigAddr' || version uint8 || threshold uint8 || PK1 || PK2 || ...)
fn (ma MultisigAccount) address() ?types.Address {
	// See go-algorand/crypto/multisig.go
	ma.validate()?
	// buffer := append([]byte(msig_add_prefix), byte(ma.version), byte(ma.threshold))
	mut buffer := msig_add_prefix.bytes()
	buffer << ma.version
	buffer << ma.threshold
	for pki in ma.pks {
		// buffer = append(buffer, pki[:]...)
		buffer << pki
	}
	return types.new_address_from_u8_array(sha512.sum512_256(buffer))
}

// validate ensures that this multisig setup is a valid multisig account
fn (ma MultisigAccount) validate() ? {
	if ma.version != 1 {
		return errMsigUnknownVersion
	}
	if ma.threshold == 0 || ma.pks.len == 0 || int(ma.threshold) > ma.pks.len {
		return errMsigInvalidThreshold
	}
	return
}

// blank return true if MultisigAccount is empty
// struct containing []ed25519.PublicKey cannot be compared
fn (ma MultisigAccount) blank() bool {
	if ma.version != 0 {
		return false
	}
	if ma.threshold != 0 {
		return false
	}
	// if ma.pks != nil {
	if ma.pks.len != 0 {
		return false
	}
	return true
}

/* LogicSig support */

// logic_sig_address returns the contract (escrow) address for a LogicSig.
//
// NOTE: If the LogicSig is delegated to another account this will not
// return the delegated address of the LogicSig.
fn logic_sig_address(lsig types.LogicSig) types.Address {
	to_be_signed := program_to_sign(lsig.logic)
	checksum := sha512.sum512_256(to_be_signed)

	// mut addr := types.Address{}
	// n := copy(addr[:], checksum[:])
	addr := checksum.clone()
	// if n != ed25519.public_key_size {
	if addr.len != ed25519.public_key_size {
		panic('Generated public key has length of $addr.len, expected $ed25519.public_key_size')
	}
	return addr
}

// LogicSigAccount represents an account that can sign with a LogicSig program.
struct LogicSigAccount {
mut:
	// struct_ struct{} 			  [codec:',omitempty,omitemptyarray']

	// The underlying LogicSig object
	lsig types.LogicSig 		  [codec:'lsig']

	// The key that provided Lsig.sig, if any
	signing_key ed25519.PublicKey [codec:'sigkey']
}

// make_logic_sig_account_escrow creates a new escrow LogicSigAccount. The address
// of this account will be a hash of its program.
// Deprecated: This method is deprecated for not applying basic sanity check over program bytes,
// use `make_logic_sig_account_escrow_checked` instead.
fn make_logic_sig_account_escrow(program []u8, args [][]u8) LogicSigAccount {
	return LogicSigAccount{
		lsig: types.LogicSig{
			logic: program,
			args:  args,
		},
	}
}

// make_logic_sig_account_escrow_checked creates a new escrow LogicSigAccount.
// The address of this account will be a hash of its program.
fn make_logic_sig_account_escrow_checked(program []u8, args [][]u8) ?LogicSigAccount {
	// lsig := make_logic_sig(program, args, unsafe { nil }, MultisigAccount{})?
	empty_priv_key := []u8{}
	lsig := make_logic_sig(program, args, ed25519.PrivateKey(empty_priv_key), MultisigAccount{})?
	return LogicSigAccount{lsig: lsig}
}

// make_logic_sig_account_delegated creates a new delegated LogicSigAccount. This
// type of LogicSig has the authority to sign transactions on behalf of another
// account, called the delegating account. If the delegating account is a
// multisig account, use make_logic_sig_account_delegated_msig instead.
//
// The parameter signer is the private key of the delegating account.
fn make_logic_sig_account_delegated(program []u8, args [][]u8, signer ed25519.PrivateKey) ?LogicSigAccount {
	ma := MultisigAccount{}
	lsig := make_logic_sig(program, args, signer, ma)?

	signer_account := account_from_private_key(signer)?

	return LogicSigAccount{
		lsig: lsig,
		// attach SigningKey to remember which account the signature belongs to
		signing_key: signer_account.public_key,
	}
}

// make_logic_sig_account_delegated_msig creates a new delegated LogicSigAccount.
// This type of LogicSig has the authority to sign transactions on behalf of
// another account, called the delegating account. Use this function if the
// delegating account is a multisig account, otherwise use
// make_logic_sig_account_delegated.
//
// The parameter msigAccount is the delegating multisig account.
//
// The parameter signer is the private key of one of the members of the
// delegating multisig account. Use the method AppendMultisigSignature on the
// returned LogicSigAccount to add additional signatures from other members.
fn make_logic_sig_account_delegated_msig(program []u8, args [][]u8, msigAccount MultisigAccount, signer ed25519.PrivateKey) ?LogicSigAccount {
	lsig := make_logic_sig(program, args, signer, msigAccount)?
	return LogicSigAccount{
		lsig: lsig,
		// do not attach SigningKey, since that doesn't apply to an msig signature
	}
}

// append_multisig_signature adds an additional signature from a member of the
// delegating multisig account.
//
// The LogicSigAccount must represent a delegated LogicSig backed by a multisig
// account.
fn (mut lsa LogicSigAccount) append_multisig_signature(signer ed25519.PrivateKey) ? {
	return append_multisig_to_logic_sig(mut lsa.lsig, signer)
}

// logic_sig_account_from_logic_sig creates a LogicSigAccount from an existing
// LogicSig object.
//
// The parameter signer_public_key must be present if the LogicSig is delegated
// and the delegating account is backed by a single private key (i.e. not a
// multisig account). In this case, signer_public_key must be the public key of
// the delegating account. In all other cases, an error will be returned if
// signer_public_key is present.
fn logic_sig_account_from_logic_sig(lsig types.LogicSig, signer_public_key &ed25519.PublicKey) ?LogicSigAccount {
	// hasSig := lsig.sig != (types.Signature{})
	has_sig := lsig.sig != types.zero_signature
	has_msig := !lsig.msig.blank()

	if has_sig && has_msig {
		return errLsigTooManySignatures
	}

	mut lsa := LogicSigAccount{}
	if has_sig {
		// if signer_public_key == unsafe { nil } {
		if signer_public_key.len != 0 {
			return errLsigNoPublicKey
		}

		to_be_signed := program_to_sign(lsig.logic)
		// valid := ed25519.verify(&signer_public_key, to_be_signed, lsig.sig[:])?
		valid := ed25519.verify(*signer_public_key, to_be_signed, lsig.sig)?
		if !valid {
			return errLsigInvalidPublicKey
		}

		lsa.lsig = lsig
		// lsa.SigningKey = make(ed25519.PublicKey, len(&signer_public_key))
		// copy(lsa.SigningKey, &signer_public_key)
		lsa.signing_key = signer_public_key.clone()
		return lsa
	}

	// if signer_public_key != unsafe { nil } {
	if signer_public_key.len != 0 {
		return errLsigAccountPublicKeyNotNeeded
	}

	lsa.lsig = lsig
	return lsa
}

// is_delegated returns true if and only if the LogicSig has been delegated to
// another account with a signature.
//
// Note this function only checks for the presence of a delegation signature. To
// verify the delegation signature, use VerifyLogicSig.
fn (lsa LogicSigAccount) is_delegated() bool {
	// has_sig := lsa.lsig.sig != (types.Signature{})
	has_sig := lsa.lsig.sig != types.zero_signature
	has_msig := !lsa.lsig.msig.blank()
	return has_sig || has_msig
}

// address returns the address of this LogicSigAccount.
//
// If the LogicSig is delegated to another account, this will return the address
// of that account.
//
// If the LogicSig is not delegated to another account, this will return an
// escrow address that is the hash of the LogicSig's program code.
fn (lsa LogicSigAccount) address() ?types.Address {
	// has_sig := lsa.lsig.sig != (types.Signature{})
	has_sig := lsa.lsig.sig != types.zero_signature
	has_msig := !lsa.lsig.msig.blank()

	// require at most one sig
	if has_sig && has_msig {
		return errLsigTooManySignatures
	}

	// mut addr := types.Address

	if has_sig {
		// n := copy(addr[:], lsa.signing_key)
		// if n != ed25519.public_key_size {
		addr := types.Address(lsa.signing_key.clone())
		if addr.len != ed25519.public_key_size {
			return error('Generated public key has length of $addr.len, expected $ed25519.public_key_size')
		}
		return addr
	}

	if has_msig {
		msig_account := multisig_account_from_sig(lsa.lsig.msig)?
		return msig_account.address()
	}

	return logic_sig_address(lsa.lsig)
}
