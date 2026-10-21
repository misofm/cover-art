// Copyright (c) Miso Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// `CoverArt` is a plain `copy, drop, store` value with no `ctx` anywhere in the
/// module, so single-transaction unit tests cover it without `test_scenario`.
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

#[test, expected_failure(abort_code = cover_art::EEncryptedBlob)]
fun new_rejects_encrypted_still() {
    cover_art::new(
        data::new_blob(1, confidentiality::new_encrypted(vector[1, 2, 3])),
        option::none(),
    );
}

#[test, expected_failure(abort_code = cover_art::EEncryptedBlob)]
fun new_rejects_encrypted_animation() {
    cover_art::new(
        data::new_blob(1, confidentiality::new_unencrypted()),
        option::some(data::new_blob(2, confidentiality::new_encrypted(vector[1, 2, 3]))),
    );
}
