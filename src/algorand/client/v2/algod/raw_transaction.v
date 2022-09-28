module algod

import context
// import algorand.client.v2.common
// import algorand.client.v2.common.models

// SendRawTransaction broadcasts a raw transaction to the network.
// struct SendRawTransaction {
// 	c *Client

// 	rawtxn []byte
// }

// Do performs the HTTP request
// fn (s &SendRawTransaction) Do(ctx context.Context, headers ...*common.Header) (txid string, err error) {
// 	var response models.PostTransactionsResponse
// 	// Set default Content-Type, if the user didn't specify it.
// 	addContentType := true
// 	for _, header := range headers {
// 		if strings.ToLower(header.Key) == 'content-type' {
// 			addContentType = false
// 			break
// 		}
// 	}
// 	if addContentType {
// 		headers = append(headers, &common.Header{'Content-Type', 'application/x-binary'})
// 	}
// 	err = s.c.post(ctx, &response, '/v2/transactions', nil, headers, s.rawtxn)
// 	txid = response.Txid
// 	return
// }

pub fn (mut c Client) send_raw_transaction(ctx context.Context, raw_txn []u8) ?string {
	resp := c.post(ctx, '/v2/transactions', unsafe { nil }, [], raw_txn)?
	// println('send_raw_transaction resp: $resp')
	return resp['txId'] or { 'error decoding txid' }.str()
}
