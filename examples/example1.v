module main

import context
import readline
import algorand.client.v2.algod
import algorand.crypto2 as crypto
import algorand.transaction
import algorand.mnemonic
import algorand.types

import crypto.ed25519

fn main() {
    mut readline := readline.Readline{}

	algod_address := 'http://localhost:8080'
	algod_token := 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'

    account := crypto.generate_account()
    mnemonic := mnemonic.from_private_key(account.private_key) or {
		panic('error generating mnemonic: $err')
	}
    
    from_address := account.address.str()

    println(' # Generated new wallet:')
    println('   * Address: $from_address')
    println('   * Mnemonic / Passphrase: $mnemonic\n')
    println(' # Copy your address & mnemonic, be sure to store it in a secure location.')
    readline.read_line(' > Once secured, press ENTER to continue...\n')  or {}
    println(' # Fund your new wallet using the Algorand TestNet faucet:')
    println('   *  Faucet URL: https://dispenser.testnet.aws.algodev.network?account=$from_address')
    readline.read_line(' > Once funded, press ENTER to continue...\n') or {}
	
    mut algo_client := algod.make_client(algod_address, algod_token) or {
		panic('error making client: $err')
	}

	tx_params := algo_client.get_suggested_params(context.background()) or {
		panic('error getting suggested params: $err')
	}
    // println('tx_params:')
	// println(tx_params)

	account_info := algo_client.get_account_information(context.background(), from_address) or {
		panic('error getting account info: $err')
	}
    // println('account information:')
	// println(account_info)

    println(' # Account balance: $account_info.amount microAlgos')
    readline.read_line(' > Ensure your balance is greater than 0, press ENTER to continue...\n') or {}

    to_address := '3O7OOO6B7SPHYK7AFYUQAI55EZWVAPXRLYG4ZBO52WWVA33UUAZW7766F4'
    amount := u64(1000000)
    min_fee := u64(transaction.min_txn_fee)
    note := 'Transaction Note'.bytes()
    gen_id := tx_params.genesis_id
    gen_hash := tx_params.genesis_hash
    first_round_valid := tx_params.first_round_valid
    last_round_valid := tx_params.last_round_valid
    txn := transaction.make_payment_txn_with_flat_fee(from_address, to_address, min_fee, amount, first_round_valid, last_round_valid, note, '', gen_id, gen_hash) or {
        panic('error creating transaction: $err')
    }

    // Sign the transaction
    tx_id, signed_txn := crypto.sign_transaction(account.private_key, txn) or {
		panic('failed to sign transaction: $err')
	}
    println(' # Signed transaction. Transaction ID: $tx_id\n')

    // Submit the transaction
    tx_id := algo_client.send_raw_transaction(context.background(), signed_txn) or {
        panic('failed to send transaction: $err')
    }
    // println(' # Submitted transaction $send_response'
    println(' # Submitted transaction to the Algorand TestNet, Transaction ID: $tx_id\n')
    
    // println(' # Waiting for confirmation...')
    // Wait for confirmation
    // confirmed_txn := future.wait_for_confirmation(algo_client, tx_id, 4, context.background()) or {
    //     println(('Error waiting for confirmation on tx_id: $tx_id')
    // }

    // // Display completed transaction
    // txn_json := json.MarshalIndent(confirmed_txn.transaction.txn, '', '\t') or {
    //     println(('Can not marshall txn data: $err')
    // }
    // println(('Transaction information: $txn_json\n')
    // println(('Decoded note: ${confirmed_txn.transaction.txn.note.bytestr()}\n')
    // println(('Amount sent: $confirmed_txn.transaction.txn.amount microAlgos\n')
    // println(('Fee: $confirmed_txn.transaction.txn.fee microAlgos\n')
}