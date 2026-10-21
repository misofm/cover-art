// Copyright (c) Miso Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// The evolvable cover art value used by the recording/release cover art extensions.
/// It lives outside the frozen protocol so a new format is a republish of this
/// small package. Cover art is always public: `new` rejects encrypted blobs.
module cover_art::cover_art;

// === Imports ===

use ori::data::WalrusBlob;

#[test_only]
use ori::{confidentiality, data};

// === Errors ===

const EEncryptedBlob: u64 = 0;

// === Structs ===

public struct CoverArt has copy, drop, store {
    still: WalrusBlob,
    animated: Option<WalrusBlob>,
}

// === Public Functions ===

public fun new(still: WalrusBlob, animated: Option<WalrusBlob>): CoverArt {
    assert!(!still.blob_confidentiality().is_encrypted(), EEncryptedBlob);
    animated.do_ref!(|blob| {
        assert!(!blob.blob_confidentiality().is_encrypted(), EEncryptedBlob)
    });
    CoverArt { still, animated }
}

// === View Functions ===

public fun still(self: &CoverArt): &WalrusBlob {
    &self.still
}

public fun animated(self: &CoverArt): &Option<WalrusBlob> {
    &self.animated
}

// === Test Functions ===

#[test_only]
public fun new_for_testing(): CoverArt {
    CoverArt {
        still: data::new_blob(0, confidentiality::new_unencrypted()),
        animated: option::none(),
    }
}
