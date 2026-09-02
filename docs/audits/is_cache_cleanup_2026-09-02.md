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
