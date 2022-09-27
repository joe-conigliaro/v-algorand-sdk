module algod

import v2.common

// HealthCheck returns OK if healthy.
struct HealthCheck {
	c &Client
}

// Do performs the HTTP request
// fn (s &HealthCheck) do(ctx context.Context, headers ...&common.Header) ? {
// 	return s.c.get(ctx, nil, "/health", nil, headers)
// }
