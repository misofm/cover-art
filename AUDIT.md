# Security Audit — `cover_art`

**Revision:** working tree based on `a40df38e96d221a12f42ebbbd446a5d23215a166`. Sole dependency
pin: `ori` @ `367ed5fe92a8b62da02c1116537cf08d111e0789` (`Move.toml`).
**Date:** 2026-09-02 · **Toolchain:** sui 1.78.1-722ac4fcf484

Audit of `cover_art` (52 LOC, `sources/cover_art.move`), the `CoverArt` value
type consumed by the `release_cover_art` extension. Verdict: **safe to publish
— no findings.**

## What it does

`CoverArt` is a pure value struct (`copy, drop, store`): a required
`still: WalrusBlob` plus an optional `animated: Option<WalrusBlob>`, both
references to external Walrus storage. The field types make the standalone-blob
constraint compile-time explicit, and two getters expose read-only borrows.

## Threat model

A malicious release admin attaching malformed cover references; a third party
forging or mutating another release's art.

- **Forgery/mutation of stored art:** impossible here by design — this package
  holds no state and attaches to nothing. Storage and authorization live in the
  consuming extension (`release_cover_art`), audited separately; it gates every
  write through `Release.uid_mut(cap)`.
- **Malformed references:** the field types accept only `WalrusBlob`. Whether
  the blob *exists* or *is an image* is explicitly out of scope (client-side
  convention).
- **Value-type escape hatches:** `CoverArt` has `copy`, so anyone holding one
  can duplicate it — harmless for an immutable-reference payload; there is no
  capability or identity inside it. Fields are private and there are no
  mutators, so a constructed `CoverArt` can never be altered after `new`.

## Findings

None.

## Edge cases verified

- `animated: none` accepted (`new_still_only`).
- `#[test_only] new_for_testing` constructs an unencrypted `WalrusBlob` and is
  absent from published bytecode.

## Verification

- `sui move build` passes.
- `sui move test` passes 2/2 tests covering still-only and animated
  construction. Incompatible Walrus reference shapes are rejected by the Move
  type checker rather than runtime tests.
