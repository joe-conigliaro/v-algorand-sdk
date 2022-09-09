module types

const(
	errWrongAddressByteLen = error('encoding address is the wrong length, should be $hash_len_bytes bytes')
	errWrongAddressLen = error('decoded address is the wrong length, should be ${hash_len_bytes+checksum_len_bytes} bytes')
	errWrongChecksum = error('address checksum is incorrect, did you copy the address correctly?')
)