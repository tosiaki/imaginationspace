# High-priority TODOs

## Completed: investigate `is_cache/` before changing or deleting it

Completed 2026-09-02. The raw inventory, database reconciliation, exact-copy
rule, independently verified deletion, retained-object findings, and scoped
future lifecycle rule are recorded in
`docs/audits/is_cache_cleanup_2026-09-02.md`.

The final 423 unmatched historical objects were later preserved in a verified
local content-addressed archive and removed from S3. No legacy cache objects
remain outside the active `is_cache/uploads/` namespace.

The original safety requirements are retained below as historical context.

Do not delete these objects or add an expiration lifecycle rule until their
relationships to database records and promoted objects have been examined from
raw data.

S3 inventory observed on 2026-09-02:

- prefix: `is_cache/`
- objects: 12,509
- bytes: 22,804,165,401
- oldest modification: 2019-01-10 04:05:13 UTC
- newest modification: 2024-10-27 05:42:55 UTC
- bucket versioning: disabled
- lifecycle configuration: absent

The age distribution makes abandoned uploads plausible, but age alone does not
prove that an object is unreferenced. Before proposing cleanup:

1. Export an immutable inventory containing key, size, checksum/ETag, storage
   class, and modification time.
2. Extract every cache and stored-object reference from the database without
   normalizing away the original attachment JSON.
3. Compare cache keys with database references and promoted `is/` objects.
4. Account for historical uploader key formats and inline editor attachments.
5. Produce counts and byte totals for referenced, promoted, duplicate, and
   unexplained objects, plus a sampled raw-key review.
6. Design a recoverable quarantine or backup step before any deletion, since
   bucket versioning is disabled.
7. Add a future cache lifecycle rule only after confirming the longest valid
   unfinished-upload and form-session lifetime.
