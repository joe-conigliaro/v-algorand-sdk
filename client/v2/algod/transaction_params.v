module algod

import context
// import client.v2.common
import types
import client.v2.common.models
import x.json2
// "github.com/algorand/go-algorand-sdk/client/v2/common"
// "github.com/algorand/go-algorand-sdk/client/v2/common/models"
// "github.com/algorand/go-algorand-sdk/types"


// SuggestedParams get parameters for constructing a new transaction
// struct SuggestedParams {
// 	c *Client
// }

pub fn (mut c Client) get_suggested_params(ctx context.Context) ?types.SuggestedParams {
	resp := c.get(ctx, "/v2/transactions/params", unsafe { nil }, [])?
	// resp_str := resp as string
	println('get_suggested_params resp: $resp')
	// resp_decoded := json2.raw_decode(resp_str)?
	// resp_decoded_map := resp_decoded.as_map()
	return types.SuggestedParams{
		// fee: types.MicroAlgos(resp_decoded_map['fee'])
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
