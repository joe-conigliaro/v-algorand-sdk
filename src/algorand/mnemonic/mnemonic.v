module mnemonic

import crypto.sha512

const (
	bits_per_word      = 11
	checksum_len_bits  = 11
	key_len_bytes      = 32
	mnemonic_len_words = 25
	padding_zeros      = bits_per_word - ((key_len_bytes * 8) % bits_per_word)
)

const(
	sep_str = ' '
	empty_byte = u8(0)
)

fn init() {
	// Verify expected relationship between constants
	if mnemonic_len_words*bits_per_word-checksum_len_bits != key_len_bytes*8+padding_zeros {
		panic('cannot initialize passphrase library: invalid constants')
	}
}

// from_key converts a 32-byte key into a 25 word mnemonic. The generated
// mnemonic includes a checksum. Each word in the mnemonic represents 11 bits
// of data, and the last 11 bits are reserved for the checksum.
fn from_key(key []u8) ?string {
	// Ensure the key we are passed is the expected length
	if key.len != key_len_bytes {
		return errWrongKeyLen
	}

	// Compute the checksum of these bytes
	chk := checksum(key)
	uint11_array := to_uint11_array(key)
	words := apply_words(uint11_array, wordlist)
	// return fmt.Sprintf('%s %s', strings.Join(words, ' '), chk), nil
	return '${words.join(" ")} $chk'
}

// to_key converts a mnemonic generated using this library into the source
// key used to create it. It returns an error if the passed mnemonic has an
// incorrect checksum, if the number of words is unexpected, or if one
// of the passed words is not found in the words list.
fn to_key(mnemonic string) ?[]u8 {
	// Split input on whitespace
	// words_raw := strings.Split(mnemonic, sep_str)
	words_raw := mnemonic.split(sep_str)

	// Strip out extra whitespace
	mut words := []string{}
	for word in words_raw {
		if word != '' {
			// words = append(words, word)
			words << word
		}
	}

	// Ensure the mnemonic is the correct length
	if words.len != mnemonic_len_words {
		return errWrongMnemonicLen
	}

	// Check that all words are in list
	for w in words {
		if index_of(wordlist, w) == -1 {
			return error('$w is not in the words list')
		}
	}

	// convert words to uin11array (Excluding the checksum word)
	mut uint11_array := []u32{}
	for i := 0; i < words.len-1; i++ {
		// uint11_array = append(uint11_array, u32(index_of(wordlist, words[i])))
		uint11_array << u32(index_of(wordlist, words[i]))
	}

	// convert t the key back to byte array
	mut byte_arr := to_byte_array(uint11_array)

	// We need to chop the last byte -
	// the short explanation - Since 256 is not divisible by 11, we have an extra 0x0 byte.
	// The longer explanation - When splitting the 256 bits to chunks of 11, we get 23 words and a left over of 3 bits.
	// This left gets padded with another 8 bits to the create the 24th word.
	// While converting back to byte array, our new 264 bits array is divisible by 8 but the last byte is just the padding.

	// Check that we have 33 bytes long array as expected
	if byte_arr.len != key_len_bytes+1 {
		return errWrongKeyLen
	}
	// Check that the last one is actually 0
	if byte_arr[key_len_bytes] != empty_byte {
		return errWrongChecksum
	}

	// chop it !
	// byte_arr = byte_arr[0:key_len_bytes]
	byte_arr = byte_arr[..key_len_bytes]

	// Pull out the checksum
	mnemonic_checksum := checksum(byte_arr)

	// Verify the checksum
	if mnemonic_checksum != words[words.len-1] {
		return errWrongChecksum
	}

	// Verify that we recovered the correct amount of data
	if byte_arr.len != key_len_bytes {
		panic('passphrase:Mnemonicto_key is broken: recovered wrong amount of data')
	}

	return byte_arr
}

// https://stackoverflow.com/a/50285590/356849
fn to_uint11_array(arr []u8) []u32 {
	mut buffer := u32(0)
	mut number_of_bit := u32(0)
	mut output := []u32{}

	for i := 0; i < arr.len; i++ {
		// prepend bits to buffer
		buffer |= u32(arr[i]) << number_of_bit
		number_of_bit += 8

		// if there enough bits, extract 11bit number
		if number_of_bit >= 11 {
			// 0x7FF is 2047, the max 11 bit number
			// output = append(output, buffer&0x7ff)
			output << buffer&0x7ff

			// drop chunk from buffer
			buffer = buffer >> 11
			number_of_bit -= 11
		}

	}

	if number_of_bit != 0 {
		// output = append(output, buffer&0x7ff)
		output << buffer&0x7ff
	}
	return output
}

// This function may result in an extra empty byte
// https://stackoverflow.com/a/51452614
fn to_byte_array(arr []u32) []u8 {
	mut buffer := u32(0)
	mut number_of_bits := u32(0)
	mut output := []u8{}

	for i := 0; i < arr.len; i++ {
		buffer |= u32(arr[i]) << number_of_bits
		number_of_bits += 11

		for number_of_bits >= 8 {
			// output = append(output, u8(buffer&0xff))
			output << u8(buffer&0xff)
			buffer >>= 8
			number_of_bits -= 8
		}
	}

	if buffer != 0 {
		// output = append(output, u8(buffer))
		output << u8(buffer)
	}

	return output
}

fn apply_words(arr []u32, words []string) []string {
	// res := make([]string, len(arr))
	mut res := []string{len: arr.len}
	for i := 0; i < arr.len; i++ {
		res[i] = words[arr[i]]
	}
	return res
}

fn index_of(arr []string, s string) int {
	for i, w in arr {
		if w == s {
			return i
		}
	}
	return -1
}

// Checksum returns a word that represents the 11 bit checksum of the data
fn checksum(data []u8) string {
	// Compute the full hash of the data to checksum
	full_hash := sha512.sum512_256(data)

	// Convert to 11 bits array
	// temp := full_hash[0:2]
	temp := full_hash[..2]
	chk_bytes := to_uint11_array(temp)

	return apply_words(chk_bytes, wordlist)[0]
}
