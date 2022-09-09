module main

import context
import algorand.client.v2.algod
import algorand.crypto2 as crypto
import algorand.transaction
import algorand.mnemonic

fn main() {
	algod_address := 'http://localhost:8080'
	algod_token := 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
	
    account := crypto.generate_account()
    passphrase := mnemonic.from_private_key(account.private_key) or {
		panic('error generating mnemonic: $err')
	}
    my_address := account.address.str()
	
	mut algo_client := algod.make_client(algod_address, algod_token) or {
		panic('error making client: $err')
	}

	tx_params := algo_client.get_suggested_params(context.background()) or {
		panic('error getting suggested params: $err')
	}
	println(tx_params)

	account_info := algo_client.get_account_information(context.background(), my_address) or {
		panic('error getting account info: $err')
	}
	println(account_info)

    to_addr := '3O7OOO6B7SPHYK7AFYUQAI55EZWVAPXRLYG4ZBO52WWVA33UUAZW7766F4'
    amount := u64(1000000)
    min_fee := u64(transaction.min_txn_fee)
    note := 'Hello from V'.bytes()
    gen_id := tx_params.genesis_id
    gen_hash := tx_params.genesis_hash
    first_round_valid := u64(tx_params.first_round_valid)
    last_round_valid := u64(tx_params.last_round_valid)
    txn := transaction.make_payment_txn_with_flat_fee(my_address, to_addr, min_fee, amount, first_round_valid, last_round_valid, note, '', gen_id, gen_hash) or {
        panic('error creating transaction: $err')
    }
    println(txn)

    // Sign the transaction
    tx_id, signed_txn := crypto.sign_transaction(account.private_key, txn) or {
		panic('failed to sign transaction: $err')
	}
    println('signed tx_id: $tx_id')


    // Submit the transaction
    send_response := algo_client.send_raw_transaction(context.background(), signed_txn) or {
        panic('failed to send transaction: $err')
    }
    println('Submitted transaction $send_response')

    // // Wait for confirmation
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