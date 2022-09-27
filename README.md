# v-algorand-sdk

Based Off: https://godoc.org/github.com/algorand/go-algorand-sdk

The Algorand golang SDK provides:

- HTTP clients for the algod (agreement) and kmd (key management) APIs
- Standalone functionality for interacting with the Algorand protocol, including transaction signing, message encoding, etc.

# Documentation

Until V specific documentation exists you may look at the go documentation [on godoc](https://godoc.org/github.com/algorand/go-algorand-sdk).

Additional developer documentation and examples can be found on [developer.algorand.org](https://developer.algorand.org/docs/sdks/go/)

# Examples

examples/example1.v demonstrates creating a new account (wallet & mnemonic) and submitting a transaction to the Algorand testnet

 - Setup an Algorand node (https://developer.algorand.org/docs/run-a-node/setup/install/)
 - You will choose a data directory when installing the default is `~/.algorand`
 - Start your node `goal node start -d ALGORAND_DATA_DIR`
 - Replace `algod_token` in example1.v with the contents of `ALGORAND_DATA_DIR/algod.token`
 - You may also change the destination address
 - Clone this repo: `git clone https://github.com/joe-conigliaro/v-algorand-sdk algorand`
 - Symlink the algorand module to ~/.vmodules: `ln -s /full/path/to/algorand/src/algorand ~/.vmodules/algorand` 
 - Build custom v version to run demo (these changes are not in master yet, but will be soon after some fixes):
    * `git clone https://github.com/joe-conigliaro/v algorand_v`
    * `git checkout comptime_selector_generic_call`
    * `cd algorand_v`
    * `v -cg -o algorand_v cmd/v`
 - You can now use algorand_v to run examples/example1.v: `./algorand_v ../algorand/examples/example1.v`
