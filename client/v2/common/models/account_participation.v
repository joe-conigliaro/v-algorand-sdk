module models

// AccountParticipation accountParticipation describes the parameters used by this
// account in consensus protocol.
struct AccountParticipation {
	// selection_participation_key (sel) Selection public key (if any) currently
	// registered for this round.
	selection_participation_key []byte [json:'selection-participation-key']

	// state_proof_key (stprf) Root of the state proof key (if any)
	state_proof_key []byte [json:'state-proof-key,omitempty']

	// vote_first_valid (voteFst) First round for which this participation is valid.
	vote_first_valid u64 [json:'vote-first-valid']

	// vote_key_dilution (voteKD) Number of subkeys in each batch of participation keys.
	vote_key_dilution u64 [json:'vote-key-dilution']

	// vote_last_valid (voteLst) Last round for which this participation is valid.
	vote_last_valid u64 [json:'vote-last-valid']

	// vote_participation_key (vote) root participation public key (if any) currently
	// registered for this round.
	vote_participation_key []byte [json:'vote-participation-key']
}
