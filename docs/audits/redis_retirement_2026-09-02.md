# Redis retirement audit — 2026-09-02

## Data classification

Every application Redis reference was inspected before retirement. The three
namespaces contained only state for the removed main-page minigame:

- `action`: a per-user generation counter used to stop an earlier gathering,
  preparation, or exploration loop
- `things`: per-user minigame inventory counters
- `explore`: per-user minigame exploration progress

Action Cable also used Redis for transient pub/sub messages carrying those
counter updates. The subscription setup that could replay `things` counters
was already commented out. No Redis key was referenced by account records,
content, uploads, Shrine attachments, or any durable database relationship.

## Upload and job boundary

Redis was not the upload-job backend:

- Active Job is configured with the in-process `async` adapter.
- Shrine background promotion hooks are commented out.
- No worker dyno is running.
- The Procfile's Sidekiq command was stale and could not run because Sidekiq is
  not a bundled dependency.

Uploaded files live in S3 and attachment metadata lives in PostgreSQL. Removing
Redis therefore does not remove or strand upload data.

## Retirement

The Redis initializer, namespace gems, obsolete key-rename task, minigame job,
minigame Action Cable channel, and its browser subscription were removed. The
inactive production Cable adapter now uses process-local `async`, so Rails boot
has no Redis dependency. The stale worker process declaration was also removed.

The Redis Cloud endpoint was already unreachable because its provider hostname
did not resolve. Its free add-on can now be removed without affecting an active
or durable application feature.
