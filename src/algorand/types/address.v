module types

import crypto.sha512
import encoding.base32

pub const (
	checksum_len_bytes = 4
	// hash_len_bytes     = sha512.size256 // TODO: compiler fix. this should work (cant see a reason why it wouldn't be possible)
	hash_len_bytes     = 32
)

// Address represents an Algorand address.
// pub type Address = [hash_len_bytes]u8
pub type Address = []u8

pub fn (s Address) to_u8_array() []u8 {
	return s
}

pub fn new_address_from_u8_array(a []u8) Address {
	return a
}

// TODO
pub fn new_address() Address {
	// pub fn new_address() []u8 {
	return []u8{len: types.hash_len_bytes}
}

// String grabs a human-readable representation of the address. This
// representation includes a 4-byte checksum.
// fn (a Address) string() string {
pub fn (a Address) str() string {
	// Compute the checksum
	// checksum_hash := sha512.Sum512_256(a[:])
	checksum_hash := sha512.sum512_256(a)
	checksum_len_bytes_ := checksum_hash[types.hash_len_bytes - types.checksum_len_bytes..]

	// Append the checksum and encode as base32
	// checksum_address := append(a[:], checksum_len_bytes...)
	mut checksum_address := a.clone()
	checksum_address << checksum_len_bytes_

	// encoded_addr := base32.new_std_encoding_with_padding(base32.no_padding).encode_to_string(checksum_address)
	// println(checksum_address.bytestr())
	// println('# checksum_address len: $checksum_address.len')
	// println('# encoded_addr: $encoded_addr')
	// return base32.StdEncoding.WithPadding(base32.NoPadding).EncodeToString(checksum_address)
	return base32.new_std_encoding_with_padding(base32.no_padding).encode_to_string(checksum_address)
}

// zero_address is Address with all zero bytes. For handy == != comparisons.
const (
	// zero_address Address = [hash_len_bytes]byte{}
	zero_address = new_address()
)

// is_zero returs true if the Address is all zero bytes.
fn (a Address) is_zero() bool {
	return a == types.zero_address
}

// decode_address turns a checksum address string into an Address object. It
// checks that the checksum is correct, and returns an error if it's not.
pub fn decode_address(addr string) ?Address {
	// Interpret the address as base32
	// decoded, err := base32.StdEncoding.WithPadding(base32.NoPadding).DecodeString(addr)
	decoded := base32.new_std_encoding_with_padding(base32.no_padding).decode_string(addr)?

	// Ensure the decoded address is the correct length
	// if decoded.len != a.len+checksum_len_bytes {
	if decoded.len != types.hash_len_bytes + types.checksum_len_bytes {
		return err_wrong_address_len
	}

	// Split into address + checksum
	// address_bytes := decoded[..a.len]
	// checksum_bytes := decoded[a.len..]
	address_bytes := decoded[..types.hash_len_bytes]
	checksum_bytes := decoded[types.hash_len_bytes..]

	// Compute the expected checksum
	checksum_hash := sha512.sum512_256(address_bytes)
	expected_checksum_bytes := checksum_hash[types.hash_len_bytes - types.checksum_len_bytes..]

	// println('address_bytes.len: $address_bytes.len')
	// println('address_bytes: $address_bytes')
	// println('decoded: $decoded')
	// println('hash_len_bytes-checksum_len_bytes: ${hash_len_bytes-checksum_len_bytes}')
	// println('checksum_hash: $checksum_hash')
	// println('checksum_bytes: $checksum_bytes')
	// println('expected_checksum_bytes: $expected_checksum_bytes')

	// Check the checksum
	// if !bytes.Equal(expected_checksum_bytes, checksum_bytes) {
	if expected_checksum_bytes != checksum_bytes {
		return err_wrong_checksum
	}

	// Checksum is good, copy address bytes into output
	// copy(a[:], address_bytes)
	return address_bytes.clone()
}

// encode_address turns a byte slice into the human readable representation of the address.
// This representation includes a 4-byte checksum
fn encode_address(addr []byte) ?string {
	if addr.len != types.hash_len_bytes {
		return err_wrong_address_byte_len
	}

	// address := Address{}
	// copy(address[:], addr)
	address := addr.clone()
	return address.str()
}
