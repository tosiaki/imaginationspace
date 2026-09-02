# `is_cache/` cleanup audit — 2026-09-02

This audit was produced from raw, paginated S3 `ListObjectsV2` results and raw
`ShrinePicture.picture_data` JSON. No telemetry summaries were used to decide
which objects were safe to remove.

## Inventory before cleanup

- Bucket objects: 53,293
- `is_cache/` objects: 12,509
- `is_cache/` bytes: 22,804,165,401
- Exact-copy cleanup candidates: 12,086 objects / 22,330,692,701 bytes
- Retained unmatched objects: 423 objects / 473,472,700 bytes
- Distinct byte signatures among retained objects: 358
- Retained objects in internal duplicate groups: 115 objects in 50 groups
- Retained zero-byte objects: 9

An exact-copy candidate has the same S3 ETag and byte size as at least one
object outside `is_cache/`. Each manifest entry records one surviving object,
chosen as the timestamp-nearest exact match. Of the candidates, 12,049 had
their nearest exact match under `is/`; 11,983 nearest matches were within one
hour and 12,077 were within one day.

The retained sample was manually inspected through a local, short-lived
private gallery. Nonzero samples were complete readable images, not visibly
truncated files. The retained set includes repeated upload attempts, nine
zero-byte failed uploads, orphan database references, and images with no exact
byte match elsewhere. These remain untouched for a later, lower-priority
investigation.

## Evidence manifest

`is_cache_exact_copy_cleanup_2026-09-02.json.gz` contains the complete sorted
target list, including cache key, byte size, ETag, modification time, and the
key and modification time of a surviving exact copy.

- Uncompressed JSON SHA-256:
  `9f7fb5db10434ea7b71ea13ed1859d3a4485c04b75802333ec5f1a5f09b5c2b3`
- Compressed file SHA-256:
  `9430fa2a6d6d84f6d1ddbf93a20606ff412668995d76a0b59d2b7ef0b6b5db50`
- Canonical sorted target projection SHA-256:
  `e5bd5260a3eda6a2d4848887b209055f45bcadc7a1eb28e59c3577b63c855279`

## Deletion safety contract

The deletion must independently re-list the bucket, re-derive candidates from
the exact ETag-and-size rule, construct the same canonical target document,
and compare its target projection with this manifest before issuing batched S3
deletes. Any mismatch must abort the operation. Only `is_cache/` keys listed in
the manifest may be deleted; all unmatched objects must remain.

## Cleanup result

The cleanup re-derived a canonical target projection SHA-256 of
`e5bd5260a3eda6a2d4848887b209055f45bcadc7a1eb28e59c3577b63c855279`,
matching the evidence manifest, before issuing any delete request.

- Deleted: 12,086 objects / 22,330,692,701 bytes
- S3 delete errors: 0
- Manifest targets still present after deletion: 0
- Retained: 423 objects / 473,472,700 bytes

Bucket versioning was not enabled, so the deleted cache objects are not
recoverable from `is_cache/`. Each was deleted only after verifying a current
byte-identical survivor outside that prefix, recorded in the evidence
manifest.

The post-cleanup database reconciliation found 36 orphan cache-reference rows
covering 28 unique keys. Nineteen rows still point to retained objects and 17
point to deleted exact-copy objects. All 36 remain unattached: none has both a
`page_type` and `page_id`. No database rows were changed during this cleanup.

## Future cache lifecycle

Release v421 (`2247dbe`) moved all newly signed direct uploads into the
`is_cache/uploads/` namespace. The signer and page-upload authorizer accept
only keys in that namespace.

After confirming the bucket still had no lifecycle configuration, the enabled
S3 rule `expire-imaginationspace-direct-upload-cache` was installed with:

- Prefix: `is_cache/uploads/`
- Object expiration: 7 days
- Incomplete multipart upload abortion: 1 day

The rule cannot match the 423 retained historical objects because those use
legacy keys outside `is_cache/uploads/`. The application currently uses
single-part direct uploads, but the multipart setting prevents future aborted
multipart sessions from accumulating if that implementation changes.

## Historical-object archival and removal

The remaining 423 legacy cache objects were subsequently archived locally
before removal from S3. The archive is stored outside the repository at:

`E:\imaginationspace-archives\is_cache-legacy-2026-09-02`

The content-addressed archive contains a manifest preserving every original S3
key, size, ETag, modification time, storage class, payload SHA-256, and blob
mapping. This avoids losing key provenance while storing internally duplicated
payloads only once.

- manifest objects: 423
- manifest logical bytes: 473,472,700
- unique SHA-256 blobs: 358
- unique bytes stored locally: 331,493,496
- manifest SHA-256:
  `b398a5054d5cf6f7205167b4fa4e3e2653f89959fff9b2c7a4bba9bc9e5b3ea6`

Before deletion, the archival utility independently re-listed the live prefix
and required every key, size, ETag, modification time, and storage class to
match the manifest. It then rechecked the size and SHA-256 of every local blob.
Only after all checks passed were the 423 exact manifest keys deleted.

- deleted: 423 objects / 473,472,700 bytes
- deletion errors: 0
- archived keys still present after deletion: 0
- remaining legacy objects outside `is_cache/uploads/`: 0

The active `is_cache/uploads/` namespace was explicitly excluded from both the
archive and deletion. At the end of this S3 phase, the 36 previously identified
unattached database rows remained unchanged; their historical S3 targets were
available through the local archive when they were among these retained objects
or through the previously documented exact-copy survivor when they referred to
the earlier cleanup set. Their later database cleanup is documented below.

The local archive was subsequently copied to the removable volume labelled
`Lexar` at:

`F:\imaginationspace-archives\is_cache-legacy-2026-09-02`

Although Windows reported the FAT32 volume health as `Warning`, a full
post-copy verification succeeded: the manifest digest matched and all 358
unique blobs matched both their recorded sizes and SHA-256 digests. The copy is
an interim backup and is intended to move into another project's archival
system later; that transfer should be recorded and independently verified when
it occurs.

A second copy was later placed on the healthy NTFS volume labelled `My Book`
at:

`G:\imaginationspace-archives\is_cache-legacy-2026-09-02`

The G: copy was independently verified rather than inferred from the copy
operation: its manifest SHA-256 matched and all 358 unique blobs matched their
recorded sizes and SHA-256 digests. Another mounted volume was also labelled
`My Book`, so the drive letter and archive path are material parts of this
record.

## Orphan cache-reference row inspection and removal

Before database deletion, all 36 rows were re-read from production with their
raw `picture_data`. Every row had null `page_type` and `page_id`, had
`inline_picture = false`, and pointed to Shrine cache storage. The set contained
28 unique cache keys:

- 19 rows referred to objects preserved in the local archive.
- 17 rows referred to objects from the earlier exact-copy cleanup.
- Nine rows described zero-byte legacy GIF uploads.
- Several clusters repeated the same key and metadata across multiple rows,
  consistent with retried or interrupted attachment creation.

Adjacent-row and timestamp checks found successful page-import activity around
several clusters. Exact-copy survivors included promoted objects associated
with pages 4086, 7924, 8355, 9560, 11497, and 11500; some other promoted copies
used an orphan row's own ID without completing its database association. The
2019 `028.png` cache object also preceded article 991's page-import sequence by
about six minutes. These observations explain the rows as incomplete upload or
association attempts rather than live page attachments.

Heroku database backup `b607` completed before deletion. A canonical projection
of row ID, association fields, inline flag, and raw attachment JSON contained
exactly 36 rows and had SHA-256:

`de3f781c7499539a2fb4f08a6039133388cad162503c0b70cf58e3b2d8592587`

The deletion transaction locked and re-derived that exact projection, aborting
unless both its ordered IDs and digest matched. It then deleted exactly the 36
rows. The production cache-orphan predicate returned zero afterward.

This exposed a separate historical residue that was not deleted:

- 10,450 unattached `ShrinePicture` rows have null `picture_data` and therefore
  contain no attachment reference.
- Ten unattached rows contain stored original and derivative attachment JSON.
  No indirect references to their `picture/<id>/` paths were found in page
  content, page display-image fields, or signal-boost comments, but their S3
  objects require a separate archive and exact-reference audit before removal.

### Detached stored-object follow-up

The ten content-bearing rows were compared with a fresh raw inventory of all
40,784 bucket objects. Together, their `is/picture/<id>/` prefixes contain 30
objects (original, show-page, and thumbnail variants) totaling 16,443,453
bytes.

Every original payload has at least one exact ETag-and-size match elsewhere in
the bucket. Some derived show-page and thumbnail objects do not have an exact
match, however. Therefore, original-image duplication alone is not a safe
deletion rule for these prefixes. The complete 30-object set remains untouched
and should be archived with payload hashes before either its S3 objects or ten
database rows are removed.

The 30 objects were subsequently archived in content-addressed form at both:

- `C:\Users\aworl\Documents\imaginationspace-archives\detached-store-2026-09-02`
- `G:\imaginationspace-archives\detached-store-2026-09-02`

The archive contains 28 unique payload blobs. Both copies were independently
verified against the manifest and every payload SHA-256 before deletion.

- objects: 30
- logical bytes: 16,443,453
- unique blobs: 28
- manifest SHA-256:
  `fa3b7791a955c5ebdd16c16e878ea7b2f6e4b86f125395e892a3aba5746f5a2f`

The deletion phase re-listed only the ten recorded `is/picture/<id>/` prefixes,
required the live key/size/ETag/timestamp/storage-class projection to match the
manifest, and re-hashed every local payload. It then deleted exactly 30 objects
with no errors and verified that all ten target prefixes were empty.

The corresponding ten database rows were separately locked and checked against
a canonical raw-row SHA-256 of
`db1279e9912e036189b6480714748d1957df0a80a9fc7c7ed6cd4016126427db`.
Exactly those ten rows were deleted, leaving no unattached row with non-null
attachment data.

### Empty historical row cleanup

The remaining 10,450 unattached rows were all uniform empty shells:

- `page_type` null
- `page_id` null
- `picture_data` null
- `inline_picture = false`

Their ordered ID projection ranged from 353 through 19,441 and had SHA-256
`81b486fff22433727aaa3d4e2b92197d33b20a8705bc6a3b2be688e8e809ed89`.
A transaction locked and re-derived that exact set and deleted only those IDs.
Post-deletion verification found zero empty targets and zero unattached
`ShrinePicture` rows of any kind. The 11,298 associated picture rows remained.
