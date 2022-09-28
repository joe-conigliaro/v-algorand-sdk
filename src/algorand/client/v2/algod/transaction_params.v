module algod

import context
import types
// import client.v2.common
// import client.v2.common.models
// import x.json2
import encoding.base64

// SuggestedParams get parameters for constructing a new transaction
// struct SuggestedParams {
// 	c *Client
// }

pub fn (mut c Client) get_suggested_params(ctx context.Context) ?types.SuggestedParams {
	resp := c.get(ctx, '/v2/transactions/params', unsafe { nil }, [])?
	// TODO automatic decode
	return types.SuggestedParams{
		fee: types.MicroAlgos(resp['fee'] or { 0 }.u64())
		genesis_id: resp['genesis-id'] or { 'missing' }.str()
		genesis_hash: base64.decode(resp['genesis-hash'] or { 'missing' }.str()) // eiip
		first_round_valid: types.Round(resp['last-round'] or { 0 }.u64())
		last_round_valid: types.Round(resp['last-round'] or { 0 }.u64() + 1000)
		consensus_version: resp['consensus-version'] or { 'missing' }.str()
		min_fee: resp['min-fee'] or { 0 }.u64()
	}
}

// // Do performs the HTTP request
// func (s *SuggestedParams) Do(ctx context.Context, headers ...*common.Header) (params types.SuggestedParams, err error) {
// 	var response models.TransactionParametersResponse
// 	err = s.c.get(ctx, &response, "/v2/transactions/params", nil, headers)
// 	params = types.SuggestedParams{
// 		Fee:              types.MicroAlgos(response.Fee),
// 		GenesisID:        response.GenesisId,
// 		GenesisHash:      response.GenesisHash,
// 		FirstRoundValid:  types.Round(response.LastRound),
// 		LastRoundValid:   types.Round(response.LastRound + 1000),
// 		ConsensusVersion: response.ConsensusVersion,
// 		MinFee:           response.MinFee,
// 	}
// 	return
// }
