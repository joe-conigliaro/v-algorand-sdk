module mnemonic

const (
	err_wrong_key_len      = error('key length must be $key_len_bytes bytes')
	err_wrong_mnemonic_len = error('mnemonic must be $mnemonic_len_words words')
	err_wrong_checksum     = error('checksum failed to validate')
)
