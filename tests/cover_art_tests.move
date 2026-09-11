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
use sui::event;

#[test]
fun new_still_only() {
    let events_before = event::num_events();
    let art = cover_art::new(
        data::new_blob(1, confidentiality::new_unencrypted()),
        option::none(),
    );
    assert!(event::num_events() == events_before);
    assert!(art.still().blob_id() == 1);
    assert!(art.animated().is_none());
    assert!(event::num_events() == events_before);
}

#[test]
fun new_with_animation() {
    let events_before = event::num_events();
    let art = cover_art::new(
        data::new_blob(1, confidentiality::new_unencrypted()),
        option::some(data::new_blob(2, confidentiality::new_unencrypted())),
    );
    assert!(event::num_events() == events_before);
    assert!(art.still().blob_id() == 1);
    assert!(art.animated().is_some());
    assert!(art.animated().borrow().blob_id() == 2);
    assert!(event::num_events() == events_before);
}

#[test]
fun new_preserves_encrypted_confidentiality() {
    let sealed_dek = vector[1, 2, 3];
    let events_before = event::num_events();
    let art = cover_art::new(
        data::new_blob(1, confidentiality::new_encrypted(sealed_dek)),
        option::none(),
    );
    assert!(event::num_events() == events_before);
    let confidentiality = art.still().blob_confidentiality();
    assert!(confidentiality.is_encrypted());
    assert!(*confidentiality.sealed_dek() == sealed_dek);
    assert!(event::num_events() == events_before);
}
