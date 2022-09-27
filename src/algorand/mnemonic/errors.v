module mnemonic

const(
	errWrongKeyLen = error('key length must be $key_len_bytes bytes')
	errWrongMnemonicLen = error('mnemonic must be $mnemonic_len_words words')
	errWrongChecksum = error('checksum failed to validate')
)