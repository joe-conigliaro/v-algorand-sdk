module types

// Bid represents a bid by a user as part of an auction.
pub struct Bid {
	struct_ struct{} [codec:',omitempty,omitemptyarray']

	// bidder_key identifies the bidder placing this bid.
	bidder_key Address [codec:'bidder']

	// bid_currency specifies how much external currency the bidder
	// is putting in with this bid.
	bid_currency u64 [codec:'cur']

	// max_price specifies the maximum price, in units of external
	// currency per Algo, that the bidder is willing to pay.
	// This must be at least as high as the current price of the
	// auction in the block in which this bid appears.
	max_price u64 [codec:'price']

	// bid_id identifies this bid.  The first bid by a bidder (identified
	// by bidder_key) with a particular bid_id on the blockchain will be
	// considered, preventing replay of bids.  Specifying a different
	// bid_id allows the bidder to place multiple bids in an auction.
	bid_id u64 [codec:'id']

	// auction_key specifies the auction for this bid.
	auction_key Address [codec:'auc']

	// auction_id identifies the auction for which this bid is intended.
	auction_id u64 [codec:'aid']
}

// SignedBid represents a signed bid by a bidder.
pub struct SignedBid {
	struct_ struct{} [codec:',omitempty,omitemptyarray']

	// bid contains information about the bid.
	bid Bid [codec:'bid']

	// sig is a signature by the bidder, as identified in the bid
	// (Bid.bidder_key) over the hash of the Bid.
	sig Signature [codec:'sig']
}

// NoteFieldType indicates a type of auction message encoded into a
// transaction's Note field.
type NoteFieldType = string

pub const (
	// note_deposit indicates a SignedDeposit message.
	note_deposit	= NoteFieldType('d')

	// note_bid indicates a SignedBid message.
	note_bid     	= NoteFieldType('b')

	// note_settlement indicates a SignedSettlement message.
	note_settlement = NoteFieldType('s')

	// note_params indicates a SignedParams message.
	note_params     = NoteFieldType('p')
)

// NoteField is the struct that represents an auction message.
pub struct NoteField {
	struct_ struct{} [codec:',omitempty,omitemptyarray']

	// type_ indicates which type of a message this is
	type_ NoteFieldType [codec:'t']

	// signed_bid, for note_bid type
	signed_bid SignedBid [codec:'b']
}
