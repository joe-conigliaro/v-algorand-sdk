module algod

import context
// import net.http
import v2.common
// import v2.common.models
import x.json2

const auth_header = 'X-Algo-API-Token'

// type Client = common.Client
struct Client {
pub mut:
	c common.Client
}

// get performs a GET request to the specific path against the server, assumes JSON resp
fn (mut c Client) get<T>(ctx context.Context, path string, body T, headers []&common.Header) ?map[string]json2.Any {
	// mut c2 := unsafe { (&common.Client(c)) }
	return c.c.get(ctx, path, body, headers)
}

// getMsgpack performs a GET request to the specific path against the server, assumes msgpack resp
fn (mut c Client) get_msgpack<T>(ctx_1 context.Context, response_1 T, path_1 string, body_1 T, headers_1 []&common.Header) ?map[string]json2.Any {
	return c.c.get_raw_msgpack(ctx_1, response_1, path_1, body_1, headers_1)
}

// getMsgpack performs a GET request to the specific path against the server, assumes msgpack resp
fn (mut c Client) get_raw<T>(ctx_2 context.Context, path_2 string, body_2 T, headers_2 []&common.Header) ?[]u8 {
	return c.c.get_raw(ctx_2, path_2, body_2, headers_2)
}

// post sends a POST request to the given path with the given request obj
fn (mut c Client) post<T>(ctx_3 context.Context, path_3 string, params T, headers_3 []&common.Header, body []u8) ?map[string]json2.Any {
	return c.c.post(ctx_3, path_3, params, headers_3, body)
}

// MakeClient is the factory for constructing a ClientV2 for a given endpo
pub fn make_client(address string, apiToken string) ?&Client {
	return &Client(common.make_client(address, algod.auth_header, apiToken)?)
}

// MakeClientWithHeaders is the factory for constructing a ClientV2 f
pub fn make_client_with_headers(address_1 string, apiToken_1 string, headers_4 []&common.Header) ?&Client {
	mut common_client_with_headers := common.make_client_with_headers(address_1, algod.auth_header,
		apiToken_1, headers_4)?
	return &Client(common_client_with_headers)
}

// pub fn (mut c Client) health_check() &HealthCheck {
// 	return &HealthCheck{
// 		c: c
// 	}
// }

// pub fn (mut c Client) get_genesis() &GetGenesis {
// 	return &GetGenesis{
// 		c: c
// 	}
// }

// pub fn (mut c Client) versions() &Versions {
// 	return &Versions{
// 		c: c
// 	}
// }

// pub fn (mut c Client) account_information(address_2 string) &account_information {
// 	return &account_information{
// 		c: c
// 		address_2: address_2
// 	}
// }

// pub fn (mut c_1 Client) account_asset_information(address_3 string, assetId u64) &account_asset_information {
// 	return &account_asset_information{
// 		c_1: c_1
// 		address_3: address_3
// 		assetId: assetId
// 	}
// }

// pub fn (mut c_1 Client) account_application_information(address_4 string, applicationId u64) &account_application_information {
// 	return &account_application_information{
// 		c_1: c_1
// 		address_4: address_4
// 		applicationId: applicationId
// 	}
// }

// pub fn (mut c_1 Client) pending_transactions_by_address(address_5 string) &pending_transactions_by_address {
// 	return &pending_transactions_by_address{
// 		c_1: c_1
// 		address_5: address_5
// 	}
// }

// pub fn (mut c_1 Client) block(round u64) &block {
// 	return &block{
// 		c_1: c_1
// 		round: round
// 	}
// }

// pub fn (mut c_1 Client) get_proof(round_1 u64, txid string) &get_proof {
// 	return &get_proof{
// 		c_1: c_1
// 		round_1: round_1
// 		txid: txid
// 	}
// }

// pub fn (mut c_1 Client) supply() &supply {
// 	return &supply{
// 		c_1: c_1
// 	}
// }

// pub fn (mut c_1 Client) status() &status {
// 	return &status{
// 		c_1: c_1
// 	}
// }

// pub fn (mut c_1 Client) status_after_block(round_2 u64) &status_after_block {
// 	return &status_after_block{
// 		c_1: c_1
// 		round_2: round_2
// 	}
// }

// pub fn (mut c_1 Client) send_raw_transaction(rawtxn []u8) &send_raw_transaction {
// 	return &send_raw_transaction{
// 		c_1: c_1
// 		rawtxn: rawtxn
// 	}
// }

// pub fn (mut c_1 Client) suggested_params() &suggested_params {
// 	return &suggested_params{
// 		c_1: c_1
// 	}
// }

// pub fn (mut c_1 Client) pending_transactions() &pending_transactions {
// 	return &pending_transactions{
// 		c_1: c_1
// 	}
// }

pub fn (mut c Client) pending_transaction_information(txid string) &PendingTransactionInformation {
	return &PendingTransactionInformation{
		c: unsafe { c }
		txid: txid
	}
}

// pub fn (mut c_1 Client) get_application_by_id(applicationId_1 u64) &get_application_by_id {
// 	return &get_application_by_id{
// 		c_1: c_1
// 		applicationId_1: applicationId_1
// 	}
// }

// pub fn (mut c_1 Client) get_asset_by_id(assetId_1 u64) &get_asset_by_id {
// 	return &get_asset_by_id{
// 		c_1: c_1
// 		assetId_1: assetId_1
// 	}
// }

// pub fn (mut c_1 Client) teal_compile(source []u8) &teal_compile {
// 	return &teal_compile{
// 		c_1: c_1
// 		source: source
// 	}
// }

// pub fn (mut c_1 Client) teal_disassemble(source_1 []u8) &teal_disassemble {
// 	return &teal_disassemble{
// 		c_1: c_1
// 		source_1: source_1
// 	}
// }

// pub fn (mut c_1 Client) teal_dryrun(request models.DryrunRequest) &teal_dryrun {
// 	return &teal_dryrun{
// 		c_1: c_1
// 		request: request
// 	}
// }

// pub fn (mut c_1 Client) block_raw(round_3 u64) &block_raw {
// 	return &block_raw{
// 		c_1: c_1
// 		round_3: round_3
// 	}
// }
