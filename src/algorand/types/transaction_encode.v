module types

import msgpack
// import encoding.base64
// import algorand.types

// TODO: fix encoding of structs, so as not to need this manual encoding

pub fn (signed_txn SignedTxn) encode() []u8 {
	mut encoder := msgpack.new_encoder()
	encoder.write_map_start(2)
	encoder.encode_string('sig')
	encoder.encode_string_bytes_raw(signed_txn.sig)
	encoder.encode_string('txn')
	mut b := encoder.bytes()
	b << signed_txn.txn.encode()
	return b
}

pub fn (txn Transaction) encode() []u8 {
	mut encoder := msgpack.new_encoder()
	encoder.write_map_start(10)
	encoder.encode_string('amt')
	encoder.encode_uint(txn.amount)
	encoder.encode_string('fee')
	encoder.encode_uint(txn.fee)
	encoder.encode_string('fv')
	encoder.encode_uint(txn.first_valid)
	encoder.encode_string('gen')
	encoder.encode_string(txn.genesis_id)
	encoder.encode_string('gh')
	encoder.encode_string_bytes_raw(txn.genesis_hash.bytes())
	encoder.encode_string('lv')
	encoder.encode_uint(txn.last_valid)
	encoder.encode_string('note')
	encoder.encode_string_bytes_raw(txn.note)
	encoder.encode_string('rcv')
	encoder.encode_string_bytes_raw(txn.receiver)
	encoder.encode_string('snd')
	encoder.encode_string_bytes_raw(txn.sender)
	encoder.encode_string('type')
	encoder.encode_string(txn.type_)
	return encoder.bytes()
}
