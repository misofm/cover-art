// Copyright (c) Miso Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// The evolvable cover art value used by the recording/release cover art extensions.
///
/// CoverArt format changes over time (static-only → +animated → future formats).
/// Keeping it in an extension rather than immutable core means a new format is a
/// republish of this small package (or a brand-new cover art standard), not of the
/// frozen protocol. `CoverArt` references external storage via `ori::data::WalrusBlob`.
module cover_art::cover_art;

use ori::data::WalrusBlob;

// === Structs ===

/// CoverArt with a required still image and optional animation.
public struct CoverArt has copy, drop, store {
    still: WalrusBlob,
    animated: Option<WalrusBlob>,
}

// === Public Functions ===

/// Creates cover art with a still image and optional animated version.
public fun new(still: WalrusBlob, animated: Option<WalrusBlob>): CoverArt {
    CoverArt { still, animated }
}

// === View Functions ===

/// Returns a reference to the still image data.
public fun still(self: &CoverArt): &WalrusBlob {
    &self.still
}

/// Returns a reference to the optional animated cover art data.
public fun animated(self: &CoverArt): &Option<WalrusBlob> {
    &self.animated
}

// === Test Functions ===

#[test_only]
public fun new_for_testing(): CoverArt {
    use ori::{confidentiality, data};
    CoverArt {
        still: data::new_blob(0, confidentiality::new_unencrypted()),
        animated: option::none(),
    }
}
