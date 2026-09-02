# Legacy authentication audit — 2026-09-02

The production audit used direct, read-only counts against the source tables.
An initial combined aggregate was canceled by a 15-second statement timeout;
it returned no results and changed no data. Smaller indexed queries then found:

- 67 `legacy_users` rows
- 64 rows linked to users still marked `legacy_password = 1`
- 3 rows linked to users already migrated from legacy authentication
- 0 orphaned `legacy_users` rows
- `LEGACY_SALT` is present in production

## Decision

Legacy authentication cannot yet be removed: 64 accounts still depend on it.
Keep `LEGACY_SALT` and the opportunistic migration that replaces a valid legacy
password with a Devise password hash at the user's next successful login.

The compatibility path now treats a missing `legacy_users` row as an invalid
password instead of raising an exception. Tests cover successful migration,
rejected passwords, and missing credentials. Migration bypasses unrelated
modern profile validations because historical rows may predate those rules;
the password has already been verified against the stored legacy digest.

The source-controlled Devise secret was removed. Devise now derives its secret
from Rails' deployment-specific `secret_key_base`, as its default configuration
intends. This invalidates any old confirmation or password-reset tokens signed
with the former key. Those routes are currently retired, so such tokens are not
usable through the live application; login sessions continue to use Rails'
encrypted cookie configuration.

## Later cleanup gate

Only consider removing the legacy table, model path, or `LEGACY_SALT` after an
exact production count shows no users with `legacy_password = 1`. The three
already-migrated credential rows may be deleted in a separate, explicitly
reviewed data-cleanup operation, but are not removed by this change.
