# Security Audit — `cover_art`

Audited at `2065cb49bbd896ec308b211b2a4c9891bb26ba2f` (2026-10-21). Scope: package `cover_art`, module `cover_art::cover_art` (`sources/cover_art.move`), and the parts of its dependency `ori` @ `367ed5fe` that it relies on (`ori::data`, `ori::confidentiality`).

## What it does

A `copy`/`drop`/`store` value type: a required still `WalrusBlob` plus an optional animated `WalrusBlob`, both unencrypted. `release_cover_art` stores it. See [README](./README.md).

## Trust model

- No state, objects, capabilities, events or dynamic fields.
- **Anyone** may build a `CoverArt` from any unencrypted `WalrusBlob` values (`cover_art.move:26-32`).
- **Nobody** can change a `CoverArt` after `new`: its fields are private and there are no mutators (`cover_art.move:19-22`).
- Where cover art is stored, and who may set it, is decided by the consumer. `release_cover_art` gates every write with `ReleaseAdminCap`.

## Findings

**CA-1 · Info · Accepted — "always public" means declared unencrypted, not verified.** The check (`cover_art.move:27-30`) reads the `Confidentiality` tag the caller supplied. `ori::confidentiality::new_unencrypted()` is public and unconditional, so any blob, including ciphertext, can be tagged unencrypted. The contract guarantees only that no sealed key is stored with the cover. Whether a blob exists, is public, or is an image is left to clients.

**CA-2 · Info · Accepted — blob ids are not validated.** `blob_id` 0, `u256::MAX`, and the same blob used for both still and animation are all accepted (probes). Walrus existence cannot be checked on-chain.

## Checked, no finding

- An encrypted still, an encrypted animation, or both all abort `EEncryptedBlob` (`cover_art.move:27`, `29`; unit tests plus a probe). The only way to build an encrypted value is `confidentiality::new_encrypted`, which requires a non-empty sealed key, and `is_encrypted` matches exhaustively over both variants (`ori` `confidentiality.move`).
- `WalrusBlob` and `Confidentiality` have `copy, drop, store` and no identity, so copying a `CoverArt` duplicates no authority (probe `copy_equal`).
- `new_for_testing` is `#[test_only]` and does not exist in published bytecode (`cover_art.move:46-52`).
- `new` emits no events (tests). Events are the consumer's job: `release_cover_art` emits the blob ids.
- Size is fixed: two `u256` ids plus the confidentiality tags. An unencrypted tag carries no payload, so a stored `CoverArt` is constant-size.

## Operational requirements

- `Published.toml` records mainnet and testnet publications from 2026-09-17, which predate the `EEncryptedBlob` check. The deployed bytecode accepts encrypted blobs. The current source must be published fresh, and consumers must pin it.
- `ori` is pinned by git rev, and its `Published.toml` records mainnet `0xadefbe1a…`. Publishing must link against that address, not republish `ori`.

## Verification

- `sui move test --coverage`: 4/4 pass. `sui move coverage summary`: 100.00% (`cover_art`).
- `sui move build -e mainnet --warnings-are-errors` and `-e testnet`: both succeed with no warnings (sui 1.82.1).
- 5 throwaway probe tests (zero and max blob id, a shared blob, copy semantics, both blobs encrypted) all passed. They were not committed.
