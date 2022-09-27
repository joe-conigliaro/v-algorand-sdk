module crypto2

// import bytes
import crypto.rand
import crypto.sha512
import crypto.ed25519
import encoding.base32
import encoding.base64
import encoding.binary
// import encoding.msgpack
import msgpack
import algorand.types

const(
	// txid_prefix is prepended to a transaction when computing its txid
	txid_prefix = 'TX'.bytes()

	// tgid_prefix is prepended to a transaction group when computing the group ID
	tgid_prefix = 'TG'.bytes()

	// bid_prefix is prepended to a bid when signing it
	bid_prefix = 'aB'.bytes()

	// bytes_prefix is prepended to a message when signing
	bytes_prefix = 'MX'.bytes()

	// program_prefix is prepended to a logic program when computing a hash
	program_prefix = 'Program'.bytes()

	// program_data_prefix is prepended to teal sign data
	program_data_prefix = 'ProgData'.bytes()

	// app_id_prefix is prepended to application IDs in order to compute addresses
	app_id_prefix = 'appID'.bytes()
)

// RandomBytes fills the passed slice with randomness, and panics if it is
// unable to do so
// TODO:
// fn random_bytes(s []u8) {
// 	_, err := rand.Read(s)
// 	if err != nil {
// 		panic(err)
// 	}
// }

// GenerateAddressFromSK take a secret key and returns the corresponding Address
fn generate_address_from_sk(sk []u8) ?types.Address {
	edsk := ed25519.PrivateKey(sk)

	pk := edsk.public_key()
	// n := copy(a[:], []byte(pk.(ed25519.PublicKey)))
	a := types.new_address_from_u8_array(pk)
	// if n != ed25519.public_key_size {
	if a.len != ed25519.public_key_size {
		// return error('generated public key has the wrong size, expected $ed25519.public_key_size, got $n')
		return error('generated public key has the wrong size, expected $ed25519.public_key_size, got $a.len')
	}
	return a
}

fn get_tx_id(tx types.Transaction) string {
	raw_tx := raw_transaction_bytes_to_sign(tx)
	return tx_id_from_raw_txn_bytes_to_sign(raw_tx)
}

// sign_transaction accepts a private key and a transaction, and returns the
// bytes of a signed transaction ready to be broadcasted to the network
// If the SK's corresponding address is different than the txn sender's, the SK's
// corresponding address will be assigned as AuthAddr
pub fn sign_transaction(sk ed25519.PrivateKey, tx types.Transaction) ?(string, []u8) {
	s, txid := raw_sign_transaction(sk, tx)?

	// Construct the SignedTxn
	mut stx := types.SignedTxn{
		sig: s,
		txn: tx,
	}

	a := generate_address_from_sk(sk)?

	if stx.txn.sender != a {
		stx.auth_addr = a
	}

	// Encode the SignedTxn
	// stx_bytes := msgpack.encode(stx)
	// TODO:
	stx_bytes := stx.encode()

	return txid, stx_bytes
}

// raw_transaction_bytes_to_sign returns the byte form of the tx that we actually sign
// and compute txID from.
fn raw_transaction_bytes_to_sign(tx types.Transaction) []u8 {
	// Encode the transaction as msgpack
	// encoded_tx := msgpack.encode(tx)
	// TODO:
	encoded_tx := tx.encode()

	// Prepend the hashable prefix
	// msg_parts := [][]byte{txid_prefix, encoded_tx}
	// return bytes.Join(msgParts, nil)
	mut b := txid_prefix.clone()
	b << encoded_tx
	return b
}

// tx_id_from_raw_txn_bytes_to_sign computes a transaction id base32 string from raw transaction bytes
fn tx_id_from_raw_txn_bytes_to_sign(to_be_signed []u8) (string) {
	tx_id_bytes := sha512.sum512_256(to_be_signed)
	// return base32.StdEncoding.WithPadding(base32.NoPadding).EncodeToString(txidBytes[:])
	return base32.new_std_encoding_with_padding(base32.no_padding).encode_to_string(tx_id_bytes)
}

// tx_id_from_transaction is a convenience function for generating txID from txn
fn tx_id_from_transaction(tx types.Transaction) string {
	tx_id_bytes := transaction_id(tx)
	// return base32.StdEncoding.WithPadding(base32.NoPadding).EncodeToString(tx_id_bytes[:])
	return base32.new_std_encoding_with_padding(base32.no_padding).encode_to_string(tx_id_bytes)
}

// transaction_id is the unique identifier for a Transaction in progress
fn transaction_id(tx types.Transaction) []u8 {
	to_be_signed := raw_transaction_bytes_to_sign(tx)
	tx_id_32 := sha512.sum512_256(to_be_signed)
	// return tx_id_32[:]
	return tx_id_32
}

// transaction_id_string is a base32 representation of a TransactionID
fn transaction_id_string(tx types.Transaction) string {
	// txid = base32.StdEncoding.WithPadding(base32.NoPadding).EncodeToString(transaction_id(tx))
	return base32.new_std_encoding_with_padding(base32.no_padding).encode_to_string(transaction_id(tx))
}

// rawSignTransaction signs the msgpack-encoded tx (with prepended 'TX' prefix), and returns the sig and txid
fn raw_sign_transaction(sk ed25519.PrivateKey, tx types.Transaction) ?(types.Signature, string) {
	to_be_signed := raw_transaction_bytes_to_sign(tx)

	// Sign the encoded transaction
	signature := ed25519.sign(sk, to_be_signed)?

	// Copy the resulting signature into a Signature, and check that it's
	// the expected length
	// mut s := types.Signature{}
	s := types.Signature(signature)
	// n := copy(s[:], signature)
	// if n != s.len {
	if signature.len != s.len {
		return errInvalidSignatureReturned
	}
	// Populate tx_id
	tx_id := tx_id_from_raw_txn_bytes_to_sign(to_be_signed)
	return s, tx_id
}

// sign_bytes signs the bytes and returns the signature
fn sign_bytes(sk ed25519.PrivateKey, bytes_to_sign []u8) ?[]u8 {
	// prepend the prefix for signing bytes
	// to_be_signed := bytes.Join([][]u8{bytes_prefix, bytes_to_sign}, nil)
	mut to_be_signed := bytes_prefix.clone()
	to_be_signed << bytes_to_sign

	// sign the bytes
	return ed25519.sign(sk, to_be_signed)
}

// VerifyBytes verifies that the signature is valid
fn verify_bytes(pk ed25519.PublicKey, message []u8, signature []u8) bool {
	// msg_parts := [][]byte{bytes_prefix, message}
	// to_be_verified := bytes.Join(msg_parts, nil)
	mut to_be_verified := bytes_prefix.clone()
	to_be_verified << message
	// return ed25519.verify(pk, to_be_verified, signature) or { 
	// 	false
	// }
	if res := ed25519.verify(pk, to_be_verified, signature) {
		println('#### res: $res')
		return res
	}
	return false
}

// SignBid accepts a private key and a bid, and returns the signature of the
// bid under that key
fn sign_bid(sk ed25519.PrivateKey, bid types.Bid) ?[]u8 {
	// Encode the bid as msgpack
	encoded_bid := msgpack.encode(bid)

	// Prepend the hashable prefix
	// msg_parts := [][]byte{bid_prefix, encoded_bid}
	// toBeSigned := bytes.Join(msg_parts, nil)
	mut to_be_signed := bid_prefix.clone()
	to_be_signed << encoded_bid

	// Sign the encoded bid
	sig := ed25519.sign(sk, to_be_signed)?

	// mut s := types.Signature{}
	s := types.Signature(sig)
	// n := copy(s[:], sig)
	// if n != s.len {
	if sig.len != s.len {
		return errInvalidSignatureReturned
	}

	sb := types.SignedBid{
		bid: bid,
		sig: s,
	}

	nf := types.NoteField{
		type_:      types.note_bid,
		signed_bid: sb,
	}

	return msgpack.encode(nf)
}

/* Multisig Support */

// type signer func() (signature types.Signature, err error)
type Signer = fn() ?types.Signature

// Service function to make a single signature in Multisig
fn multisig_single(sk ed25519.PrivateKey, ma MultisigAccount, custom_signer Signer) ?(types.MultisigSig, int) {
	// check that sk.pk exists in the list of public keys in MultisigAccount ma
	mut my_index := ma.pks.len
	// myPublicKey := sk.Public().(ed25519.PublicKey)
	my_public_key := sk.public_key()
	for i := 0; i < ma.pks.len; i++ {
		// if bytes.Equal(my_public_key, ma.pks[i]) {
		if my_public_key == ma.pks[i] {
			my_index = i
		}
	}
	if my_index == ma.pks.len {
		return errMsigInvalidSecretKey
	}

	// now, create the signed transaction
	mut msig := types.MultisigSig{}
	msig.version = ma.version
	msig.threshold = ma.threshold
	// msig.subsigs = make([]types.MultisigSubsig, len(ma.pks))
	msig.subsigs = []types.MultisigSubsig{len: ma.pks.len}
	for i := 0; i < ma.pks.len; i++ {
		// c := make([]u8, len(ma.pks[i]))
		// copy(c, ma.pks[i])
		// msig.subsigs[i].key = c
		msig.subsigs[i].key = ma.pks[i].clone()
	}
	// rawSig, err := custom_signer()
	// if err != nil {
	// 	return
	// }
	raw_sig := custom_signer()?

	msig.subsigs[my_index].sig = raw_sig
	return msig, my_index
}

// sign_multisig_transaction signs the given transaction, and multisig preimage, with the
// private key, returning the bytes of a signed transaction with the multisig field
// partially populated, ready to be passed to other multisig signers to sign or broadcast.
fn sign_multisig_transaction(sk ed25519.PrivateKey, ma MultisigAccount, tx types.Transaction) ?(string, []u8) {
	ma.validate()?

	// this signer signs a transaction and sets txid from the closure
	// customSigner := func() (rawSig types.Signature, err error) {
	// 	rawSig, txid, err = raw_sign_transaction(sk, tx)
	// 	return rawSig, err
	// }
	mut txid := ''
	custom_signer := fn [sk, tx, mut txid] () ?types.Signature {
		raw_sig, txid2 := raw_sign_transaction(sk, tx)?
		txid = txid2
		return raw_sig
	}
	// TODO: closure vars
	sig, _ := multisig_single(sk, ma, custom_signer)?

	// Encode the signedTxn
	mut stx := types.SignedTxn{
		msig: sig,
		txn:  tx,
	}

	ma_address := ma.address()?

	if stx.txn.sender != ma_address {
		stx.auth_addr = ma_address
	}

	stx_bytes := msgpack.encode(stx)
	return txid, stx_bytes
}

// merge_multisig_transactions merges the given (partially) signed multisig transactions, and
// returns an encoded signed multisig transaction with the component signatures.
fn merge_multisig_transactions(stxs_bytes ...[]u8) ?(string, []u8) {
	if stxs_bytes.len < 2 {
		return errMsigMergeLessThanTwo
	}
	// var sig types.MultisigSig
	// var refAddr *types.Address
	// var refTx types.Transaction
	// var refAuthAddr types.Address
	// TODO: fix all of this & reference stuff
	mut sig := types.MultisigSig{}
	mut addr := types.new_address()
	mut ref_addr := &addr
	mut ref_tx := types.Transaction{}
	mut ref_auth_addr := types.new_address()
	for part_stx_bytes in stxs_bytes {
		// part_stx := types.SignedTxn{}
		// err = msgpack.Decode(partStxBytes, &partStx)
		// if err != nil {
		// 	return
		// }
		part_stx := msgpack.decode<types.SignedTxn>(part_stx_bytes)?
		// check that multisig parameters match
		part_ma := multisig_account_from_sig(part_stx.msig)?
		// part_addr := part_ma.address()?
		mut part_addr := part_ma.address()?
		if ref_addr == unsafe { nil } {
			ref_addr = &part_addr
			// add parameters to new merged txn
			sig.version = part_stx.msig.version
			sig.threshold = part_stx.msig.threshold
			// sig.subsigs = make([]types.MultisigSubsig, part_stx.msig.subsigs.len)
			for i := 0; i < sig.subsigs.len; i++ {
				// c := make([]u8, part_stx.msig.subsigs[i].key.len)
				// copy(c, part_stx.msig.subsigs[i].key)
				// sig.subsigs[i].Key = c
				sig.subsigs[i].key = part_stx.msig.subsigs[i].key.clone()
			}
			ref_tx = part_stx.txn
			ref_auth_addr = part_stx.auth_addr
		}

		// if partAddr != *ref_addr {
		// TODO: ?
		if part_addr != ref_addr {
			return errMsigMergeKeysMismatch
		}

		if part_stx.auth_addr != ref_auth_addr {
			return errMsigMergeAuthAddrMismatch
		}

		// now, add subsignatures appropriately
		// zero_sig := types.Signature{}
		for i := 0; i < sig.subsigs.len; i++ {
			m_subsig := part_stx.msig.subsigs[i]
			if m_subsig.sig != types.zero_signature {
				if sig.subsigs[i].sig == types.zero_signature {
					sig.subsigs[i].sig = m_subsig.sig
				} else if sig.subsigs[i].sig != m_subsig.sig {
					return errMsigMergeInvalidDups
				}
			}
		}
	}
	// Encode the signedTxn
	stx := types.SignedTxn{
		msig:      sig,
		txn:       ref_tx,
		auth_addr: ref_auth_addr,
	}
	stx_bytes := msgpack.encode(stx)
	// let's also compute the txid.
	txid := tx_id_from_transaction(ref_tx)
	return txid, stx_bytes
}

// append_multisig_transaction appends the signature corresponding to the given private key,
// returning an encoded signed multisig transaction including the signature.
// While we could compute the multisig preimage from the multisig blob, we ask the caller
// to pass it back in, to explicitly check that they know who they are signing as.
fn append_multisig_transaction(sk ed25519.PrivateKey, ma MultisigAccount, pre_stx_bytes []u8) ?(string, []u8) {
	// pre_stx := types.SignedTxn{}
	// err = msgpack.Decode(preStxBytes, &preStx)
	// if err != nil {
	// 	return
	// }
	pre_stx := msgpack.decode<types.SignedTxn>(pre_stx_bytes)?
	_, part_stx_bytes := sign_multisig_transaction(sk, ma, pre_stx.txn)?
	txid, stx_bytes := merge_multisig_transactions(part_stx_bytes, pre_stx_bytes)?
	return txid, stx_bytes
}

// VerifyMultisig verifies an assembled MultisigSig
//
// addr is the address of the Multisig account
// message is the bytes there were signed
// msig is the Multisig signature to verify
fn verify_multisig(addr types.Address, message []u8, msig types.MultisigSig) bool {
	msig_account := multisig_account_from_sig(msig) or { return false }

	// if msig_address, err := msig_account.Address(); err != nil || msig_address != addr {
	// 	return false
	// }
	msig_address := msig_account.address() or { return false }
	if msig_address != addr { return false }

	// check that we don't have too many multisig subsigs
	if msig.subsigs.len > 255 {
		return false
	}

	// check that we don't have too few multisig subsigs
	if msig.subsigs.len < int(msig.threshold) {
		return false
	}

	// checks the number of non-blank signatures is no less than threshold
	mut counter := 0
	for subsigi in msig.subsigs {
		// if (subsigi.Sig != types.Signature{}) {
		if subsigi.sig != types.zero_signature {
			counter++
		}
	}
	if counter < int(msig.threshold) {
		return false
	}

	// checks individual signature verifies
	mut verified_count := u8(0)
	for subsigi in msig.subsigs {
		// if (subsigi.sig != types.Signature{}) {
		if subsigi.sig != types.zero_signature {
			// if !ed25519.verify(subsigi.Key, message, subsigi.Sig[:]) {
			ed25519.verify(subsigi.key, message, subsigi.sig) or {
				return false
			}
			verified_count++
		}
	}

	if verified_count < msig.threshold {
		return false
	}

	return true
}

// compute_group_id returns group ID for a group of transactions
// fn compute_group_id(txgroup []types.Transaction) (gid types.Digest, err error) {
fn compute_group_id(txgroup []types.Transaction) ?types.Digest {
	if txgroup.len > types.max_tx_group_size {
		// err = fmt.Errorf('txgroup too large, %v > max size %v', len(txgroup), types.max_tx_group_size)
		return error('txgroup too large, $txgroup > max size $types.max_tx_group_size')
	}
	mut group := types.TxGroup{}
	// empty := types.Digest{}
	for tx in txgroup {
		if tx.group != types.zero_digest {
			// err = fmt.Errorf('transaction %v already has a group %v', tx, tx.Group)
			return error('transaction $tx already has a group $tx.group')
		}

		tx_id := sha512.sum512_256(raw_transaction_bytes_to_sign(tx))
		// group.tx_group_hashes = append(group.tx_group_hashes, tx_id)
		group.tx_group_hashes << tx_id
	}

	encoded := msgpack.encode(group)

	// Prepend the hashable prefix and hash it
	// msg_parts := [][]u8{tgid_prefix, encoded}
	// return sha512.Sum512_256(bytes.Join(msg_parts, nil)), nil
	mut msg_parts := tgid_prefix.clone()
	msg_parts << encoded
	return sha512.sum512_256(msg_parts)
}

/* LogicSig support */

fn is_ascii_printable_byte(symbol u8) bool {
	is_break_line := symbol == `\n`
	is_std_printable := symbol >= ` ` && symbol <= `~`
	return is_break_line || is_std_printable
}

fn is_ascii_printable(program []u8) bool {
	for b in program {
		if !is_ascii_printable_byte(b) {
			return false
		}
	}
	return true
}

// sanityCheckProgram performs heuristic program validation:
// check if passed in bytes are Algorand address or is B64 encoded, rather than Teal bytes
fn sanity_check_program(program []u8) ? {
	if program.len == 0 {
		return error('empty program')
	}
	if is_ascii_printable(program) {
		// if _, err := types.DecodeAddress(string(program)); err == nil {
		if _ := types.decode_address(program.bytestr()) {
			return error('requesting program bytes, get Algorand address')
		}
		// if _, err := base64.StdEncoding.DecodeString(string(program)); err == nil {
		// TODO:
		dump('TODO:')
		// if _ := base64.StdEncoding.DecodeString(string(program)) {
		// 	return error('program should not be b64 encoded')
		// }
		return error('program bytes are all ASCII printable characters, not looking like Teal byte code')
	}
	// return nil
}

// verify_logic_sig verifies that a LogicSig contains a valid program and, if a
// delegated signature is present, that the signature is valid.
//
// The singleSigner argument is only used in the case of a delegated LogicSig
// whose delegating account is backed by a single private key (i.e. not a
// multsig account). In that case, it should be the address of the delegating
// account.
fn verify_logic_sig(lsig types.LogicSig, single_signer types.Address) bool {
	sanity_check_program(lsig.logic) or {
		return false
	}

	// has_sig := lsig.sig != (types.Signature{})
	has_sig := lsig.sig != types.zero_signature
	has_msig := !lsig.msig.blank()

	// require only one or zero sig
	if has_sig && has_msig {
		return false
	}

	to_be_signed := program_to_sign(lsig.logic)

	if has_sig {
		// return ed25519.Verify(singleSigner[:], to_be_signed, lsig.Sig[:])
		return ed25519.verify(single_signer.to_u8_array(), to_be_signed, lsig.sig) or { false }
	}

	if has_msig {
		msig_account := multisig_account_from_sig(lsig.msig) or { return false }
		addr := msig_account.address() or { return false }
		return verify_multisig(addr, to_be_signed, lsig.msig)
	}

	// the lsig account is the hash of its program bytes, nothing left to verify
	return true
}

// sign_logic_sig_transaction_with_address signs a transaction with a LogicSig.
//
// lsig_address is the address of the account that the LogicSig represents.
fn sign_logic_sig_transaction_with_address(lsig types.LogicSig, lsig_address types.Address, tx types.Transaction) ?(string, []u8) {

	if !verify_logic_sig(lsig, lsig_address) {
		return errLsigInvalidSignature
	}

	txid := tx_id_from_transaction(tx)
	// Construct the SignedTxn
	mut stx := types.SignedTxn{
		lsig: lsig,
		txn:  tx,
	}

	if stx.txn.sender != lsig_address {
		stx.auth_addr = lsig_address
	}

	// Encode the SignedTxn
	stx_bytes := msgpack.encode(stx)
	return txid, stx_bytes
}

// sign_logic_sig_account_transaction signs a transaction with a LogicSigAccount. It
// returns the TxID of the signed transaction and the raw bytes ready to be
// broadcast to the network. Note: any type of transaction can be signed by a
// LogicSig, but the network will reject the transaction if the LogicSig's
// program declines the transaction.
fn sign_logic_sig_account_transaction(logic_sig_account LogicSigAccount, tx types.Transaction) ?(string, []u8) {
	addr := logic_sig_account.address()?
	return sign_logic_sig_transaction_with_address(logic_sig_account.lsig, addr, tx)
}

// sign_logic_sig_transaction takes LogicSig object and a transaction and returns the
// bytes of a signed transaction ready to be broadcasted to the network
// Note, LogicSig actually can be attached to any transaction and it is a
// program's responsibility to approve/decline the transaction
//
// This function supports signing transactions with a sender that differs from
// the LogicSig's address, EXCEPT IF the LogicSig is delegated to a non-multisig
// account. In order to properly handle that case, create a LogicSigAccount and
// use sign_logic_sig_account_transaction instead.
fn sign_logic_sig_transaction(lsig types.LogicSig, tx types.Transaction) ?(string, []u8) {
	// has_sig := lsig.sig != (types.Signature{})
	has_sig := lsig.sig != types.zero_signature
	has_msig := !lsig.msig.blank()

	// the address that the LogicSig represents
	// mut lsig_address := types.Address{}
	lsig_address := if has_sig {
		// For a LogicSig with a non-multisig delegating account, we cannot derive
		// the address of that account from only its signature, so assume the
		// delegating account is the sender. If that's not the case, the signing
		// will fail.
		tx.Header.sender
	} else if has_msig {
		msig_account := multisig_account_from_sig(lsig.msig)?
		msig_account.address()?
	} else {
		logic_sig_address(lsig)
	}

	return sign_logic_sig_transaction_with_address(lsig, lsig_address, tx)
}

fn program_to_sign(program []u8) []u8 {
	// parts := [][]u8{program_prefix, program}
	// to_be_signed := bytes.Join(parts, nil)
	mut to_be_signed := program_prefix.clone()
	to_be_signed << program
	return to_be_signed
}

fn sign_program(sk ed25519.PrivateKey, program []u8) ?types.Signature {
	to_be_signed := program_to_sign(program)
	raw_sig := ed25519.sign(sk, to_be_signed)?
	// mut sig := types.Signature{}
	mut sig := types.new_signature()
	// n := copy(sig[:], raw_sig)
	n := copy(mut sig, raw_sig)
	if n != sig.len {
		return errInvalidSignatureReturned
	}
	return sig
}

// address_from_program returns escrow account address derived from TEAL bytecode
fn address_from_program(program []u8) types.Address {
	to_be_hashed := program_to_sign(program)
	hash := sha512.sum512_256(to_be_hashed)
	return types.Address(hash)
}

// make_logic_sig produces a new LogicSig signature.
//
// Deprecated: THIS FUNCTION IS DEPRECATED.
// It will be removed in v2 of this library.
// Use one of MakeLogicSigAccountEscrow, MakeLogicSigAccountDelegated, or
// MakeLogicSigAccountDelegatedMsig instead.
//
// The function can work in three modes:
// 1. If no sk and ma provided then it returns contract-only LogicSig
// 2. If no ma provides, it returns Sig delegated LogicSig
// 3. If both sk and ma specified the function returns Multisig delegated LogicSig
fn make_logic_sig(program []u8, args [][]u8, sk ed25519.PrivateKey, ma MultisigAccount) ?types.LogicSig {
	sanity_check_program(program)?
	
	mut lsig := types.LogicSig{}
	// if sk == nil && ma.blank() {
	// TODO: fix nil
	if sk.len == 0 && ma.blank() {
		lsig.logic = program
		lsig.args = args
		return lsig
	}

	if ma.blank() {
		sig := sign_program(sk, program)?

		lsig.logic = program
		lsig.args = args
		lsig.sig = types.Signature(sig)
		return lsig
	}

	// Format Multisig
	ma.validate()?

	// this signer signs a program
	custom_signer := fn [sk, program] () ?types.Signature {
		return sign_program(sk, program)
	}
	// TODO: custom_signer
	msig, _ := multisig_single(sk, ma, custom_signer)?

	lsig.logic = program
	lsig.args = args
	lsig.msig = msig

	return lsig
}

// append_multisig_to_logic_sig adds a new signature to multisigned LogicSig
fn append_multisig_to_logic_sig(mut lsig types.LogicSig, sk ed25519.PrivateKey) ? {
	if lsig.msig.blank() {
		return errLsigEmptyMsig
	}

	ma := multisig_account_from_sig(lsig.msig)?

	custom_signer := fn [sk, lsig] () ?types.Signature {
		return sign_program(sk, lsig.logic)
	}
	// TODO: custom_signer
	msig, idx := multisig_single(sk, ma, custom_signer)?

	lsig.msig.subsigs[idx] = msig.subsigs[idx]

	// return nil
	return
}

// teal_sign creates a signature compatible with ed25519verify opcode from contract address
fn teal_sign(sk ed25519.PrivateKey, data []u8, contract_address types.Address) ?types.Signature {
	// msg_parts := [][]u8{program_data_prefix, contract_address[:], data}
	// to_be_signed := bytes.Join(msg_parts, nil)
	mut to_be_signed := program_data_prefix.clone()
	to_be_signed << contract_address
	to_be_signed << data

	signature := ed25519.sign(sk, to_be_signed)?
	// Copy the resulting signature into a Signature, and check that it's
	// the expected length
	// mut raw_sig := types.Signature{}
	// n := copy(raw_sig[:], signature)
	raw_sig := signature.clone()
	// if n != raw_sig.len {
	if raw_sig.len != signature.len {
		return errInvalidSignatureReturned
	}
	return raw_sig
}

// teal_sign_from_program creates a signature compatible with ed25519verify opcode from raw program bytes
fn teal_sign_from_program(sk ed25519.PrivateKey, data []u8, program []u8) ?types.Signature {
	addr := address_from_program(program)
	return teal_sign(sk, data, addr)
}

// teal_verify verifies signatures generated by teal_sign and teal_sign_from_program
fn teal_verify(pk ed25519.PublicKey, data []u8, contract_address types.Address, raw_sig types.Signature) bool {
	// msg_parts := [][]u8{program_data_prefix, contract_address[:], data}
	// to_be_verified := bytes.Join(msg_parts, nil)
	mut to_be_verified := program_data_prefix.clone()
	to_be_verified << contract_address
	to_be_verified << data

	return ed25519.verify(pk, to_be_verified, raw_sig) or { false }
}

// get_application_address returns the address corresponding to an application's escrow account.
fn get_application_address(app_id u64) types.Address {
	// encoded_app_id := make([]u8, 8)
	mut encoded_app_id := []u8{len: 8}
	binary.big_endian_put_u64(mut encoded_app_id, app_id)

	// parts := [][]u8{app_id_prefix, encoded_app_id}
	// to_be_hashed := bytes.Join(parts, nil)
	mut to_be_hashed := app_id_prefix.clone()
	to_be_hashed << encoded_app_id

	hash := sha512.sum512_256(to_be_hashed)
	return types.Address(hash)
}
