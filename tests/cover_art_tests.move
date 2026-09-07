// Copyright (c) Miso Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// `CoverArt` is a pure `copy, drop, store` value (no `key`/`UID`, no `ctx`
/// parameter anywhere in the module): there is no ownership, no shared
/// object, and no sender-gated behavior for `test_scenario` to exercise.
/// Plain single-transaction unit tests cover the full use-case scope.
#[test_only]
module cover_art::cover_art_tests;

use cover_art::cover_art;
use ori::{confidentiality, data};

#[test]
fun new_still_only() {
    let art = cover_art::new(
        data::new_blob(1, confidentiality::new_unencrypted()),
        option::none(),
    );
    assert!(art.still().blob_id() == 1);
    assert!(art.animated().is_none());
}

#[test]
fun new_with_animation() {
    let art = cover_art::new(
        data::new_blob(1, confidentiality::new_unencrypted()),
        option::some(data::new_blob(2, confidentiality::new_unencrypted())),
    );
    assert!(art.still().blob_id() == 1);
    assert!(art.animated().is_some());
    assert!(art.animated().borrow().blob_id() == 2);
}

#[test]
fun new_preserves_encrypted_confidentiality() {
    let sealed_dek = vector[1, 2, 3];
    let art = cover_art::new(
        data::new_blob(1, confidentiality::new_encrypted(sealed_dek)),
        option::none(),
    );
    let confidentiality = art.still().blob_confidentiality();
    assert!(confidentiality.is_encrypted());
    assert!(*confidentiality.sealed_dek() == sealed_dek);
}
