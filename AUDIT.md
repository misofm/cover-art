# Security Audit — `cover_art`

**Revision:** working tree @ 2026-08-23 (the `misonetwork` workspace is not a
git repository — `git rev-parse` fails; no commit hash exists). Sole dependency
pin: `ori` @ `8a4dbb5f853b78eb7475063a840c4444421c5bbd` (`Move.toml`).
**Date:** 2026-08-23 · **Toolchain:** sui 1.77.2-51d177ad7d65

Audit of `cover_art` (52 LOC, `sources/cover_art.move`), the `CoverArt` value
type consumed by the `release_cover_art` extension. Verdict: **safe to publish
— no findings.**

## What it does

`CoverArt` (`cover_art.move:17`) is a pure value struct (`copy, drop, store`):
a required `still: WalrusData` plus an optional `animated: Option<WalrusData>`,
both references to external Walrus storage. The single constructor `new`
(`cover_art.move:26`) asserts via `ori::walrus_data::assert_is_blob` that both
references are standalone blobs (quilt patches rejected), and two getters
(`still`/`animated`, `cover_art.move:37,42`) expose read-only borrows.

## Threat model

A malicious release admin attaching malformed cover references; a third party
forging or mutating another release's art.

- **Forgery/mutation of stored art:** impossible here by design — this package
  holds no state and attaches to nothing. Storage and authorization live in the
  consuming extension (`release_cover_art`), audited separately; it gates every
  write through `Release.uid_mut(cap)`.
- **Malformed references:** the only validation this type promises is
  blob-vs-quilt-patch shape, and `new` enforces it on both fields
  (`cover_art.move:27-30`). `assert_is_blob` is a pure variant check (verified
  in the pinned `ori` source: `walrus_data.move`, `is_blob()` /
  `assert_is_blob`). Whether the blob *exists* or *is an image* is explicitly
  out of scope (client-side convention).
- **Value-type escape hatches:** `CoverArt` has `copy`, so anyone holding one
  can duplicate it — harmless for an immutable-reference payload; there is no
  capability or identity inside it. Fields are private and there are no
  mutators, so a constructed `CoverArt` can never be altered after `new`.

## Findings

None.

## Edge cases verified

- Quilt patch as `still` aborts; quilt patch inside `some(animated)` aborts —
  both covered by tests (`new_rejects_non_blob_still`,
  `new_rejects_non_blob_animated`).
- `animated: none` accepted (`new_still_only`).
- `#[test_only] new_for_testing` (`cover_art.move:50`) bypasses the blob assert
  but constructs only `new_blob(0)` — a valid blob anyway — and is absent from
  published bytecode.

## Verification

- **4/4 unit tests pass** (`sui move test`, sui 1.77.2): happy paths plus both
  non-blob rejections.
- Pinned `ori` dependency source read at the pinned rev to confirm
  `assert_is_blob` semantics.
