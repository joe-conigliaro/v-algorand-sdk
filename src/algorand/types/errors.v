module types

const (
	err_wrong_address_byte_len = error('encoding address is the wrong length, should be $hash_len_bytes bytes')
	err_wrong_address_len      = error('decoded address is the wrong length, should be ${
		hash_len_bytes + checksum_len_bytes} bytes')
	err_wrong_checksum         = error('address checksum is incorrect, did you copy the address correctly?')
)
