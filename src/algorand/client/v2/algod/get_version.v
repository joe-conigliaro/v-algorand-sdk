module algod

// import context
// import v2.common
// import v2.common.models

// Versions retrieves the supported API versions, binary build versions, and
// genesis information.
struct Versions {
	c &Client
}

// Do performs the HTTP request
// fn (s *Versions) Do(ctx context.Context, headers ...*common.Header) (response models.Version, err error) {
// 	err = s.c.get(ctx, &response, "/versions", nil, headers)
// 	return
// }
