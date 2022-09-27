module algod

import context
// import client.v2.common
import types
import client.v2.common.models
import x.json2
import encoding.base64
// "github.com/algorand/go-algorand-sdk/client/v2/common"
// "github.com/algorand/go-algorand-sdk/client/v2/common/models"
// "github.com/algorand/go-algorand-sdk/types"


// SuggestedParams get parameters for constructing a new transaction
// struct SuggestedParams {
// 	c *Client
// }

pub fn (mut c Client) get_suggested_params(ctx context.Context) ?types.SuggestedParams {
	resp := c.get(ctx, "/v2/transactions/params", unsafe { nil }, [])?
	// TODO automatic decode
	println(resp)
	println('resp genesis hash')
	println(base64.decode(resp['genesis-hash'].str()))
	return types.SuggestedParams{
		fee: types.MicroAlgos(resp['fee'].u64())
		genesis_id: resp['genesis-id'].str()
		genesis_hash: base64.decode(resp['genesis-hash'].str()) // eiip
		first_round_valid: types.Round(resp['last-round'].u64())
		last_round_valid: types.Round(resp['last-round'].u64() + 1000)
		consensus_version: resp['consensus-version'].str()
		min_fee: resp['min-fee'].u64()
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
