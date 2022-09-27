module algod

import context
import v2.common
import algorand.client.v2.common.models
import strconv

// AccountInformationParams contains all of the query parameters for url serialization.
struct AccountInformationParams {

	// Exclude when set to `all` will exclude asset holdings, application local state,
	// created asset parameters, any created application parameters. Defaults to
	// `none`.
	exclude string [url:'exclude,omitempty']

	// Format configures whether the response object is JSON or MessagePack encoded.
	format string [url:'format,omitempty']
}

// AccountInformation given a specific account public key, this call returns the
// accounts status, balance and spendable amounts
struct AccountInformation {
	// c *Client

	address string

	p AccountInformationParams
}

// Exclude when set to `all` will exclude asset holdings, application local state,
// created asset parameters, any created application parameters. Defaults to
// `none`.
// func (s *AccountInformation) Exclude(Exclude string) *AccountInformation {
// 	s.p.Exclude = Exclude
// 	return s
// }

// Do performs the HTTP request
// fn (s &AccountInformation) do(ctx context.Context, headers ...&common.Header) ?models.Account {
// 	resp := s.c.get(ctx, &response, fmt.Sprintf('/v2/accounts/%s', common.EscapeParams(s.address)...), s.p, headers)
// 	return
// }

pub fn (mut c Client) get_account_information(ctx context.Context, address string, headers ...&common.Header) ?models.Account {
	// resp := c.get(ctx, '/v2/address/params/' + common.escape_params(address), [], [])?
	escaped := common.escape_params(address)
	resp := c.get(ctx, '/v2/accounts/' + address, unsafe { nil }, [])?
	// println('get_account_information resp: $resp')
	// TODO: automatic decode to structure
	return models.Account{
		address: resp['address'].str() // eiiip
		amount: resp['amount'].u64()
		// TODO: all fields
	}
}
