module algod

import context
import algorand.client.v2.common
import algorand.client.v2.common.models


// Status gets the current node status.
// type Status struct {
// 	c *Client
// }

// // Do performs the HTTP request
// func (s *Status) Do(ctx context.Context, headers ...*common.Header) (response models.NodeStatus, err error) {
// 	err = s.c.get(ctx, &response, "/v2/status", nil, headers)
// 	return
// }

// pub fn (mut c Client) get_status(ctx context.Context, headers ...&common.Header) ?string {
// 	println(raw_txn.hex())
// 	// resp := c.post(ctx, "/v2/transactions", unsafe { nil }, [], raw_txn)?
// 	resp := c.get(ctx, "/v2/status", unsafe { nil }, headers)?
// 	// TODO:
// 	return models.NodeStatus{

// 	}
// }