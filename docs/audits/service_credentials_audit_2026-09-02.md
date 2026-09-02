# Service and credential audit — 2026-09-02

This audit queried only configuration presence, add-on plan metadata,
connection status, and permission mechanisms. No credential values, URLs,
account identifiers, or secret fragments were recorded.

## Redis Cloud

- Add-on: Redis Cloud 30 MB free plan
- `REDISCLOUD_URL`: present and structurally valid
- URL scheme: non-TLS `redis`
- Credentials/userinfo: present
- Redis 6 client parsing: correct
- Provider hostname DNS resolution: failed from the Heroku dyno
- Redis connection: failed before authentication because the configured host
  does not resolve

The failure was stale provider/add-on state rather than the Redis 6 URL parser.
Every application reference was subsequently traced to transient state for the
removed main-page minigame and its Action Cable broadcasts; Redis was not an
upload queue or durable content store. The dead integration and Redis gems were
removed, the Redis-free release was verified, and the free add-on was removed.

## SendGrid

- Add-on: legacy SendGrid Bronze plan, listed at $17.95/month
- Scoped `SENDGRID_API_KEY`: absent
- Legacy `SENDGRID_USERNAME` and `SENDGRID_PASSWORD`: present
- SMTP port: 587
- STARTTLS: enabled
- Authentication mode: plain within TLS
- Authentication-only connection test: successful
- Test messages sent: 0

The current SMTP credentials work, but legacy username/password credentials do
not offer the explicit least-privilege scope reporting available to a modern
SendGrid API key. Signup, confirmation, and password-reset routes remain
retired, so no presently exposed route requires outbound mail.

## AWS/S3

- Static access and secret keys are both present.
- They remain required for the newly restored direct-upload flow and for
  Shrine promotion.
- An authenticated production smoke test successfully uploaded, verified, and
  deleted a 14,971-byte object through the real browser-to-S3 path.
- A read-only IAM capability check returned `AccessDenied`; the deployed
  application key cannot inspect or rotate its own IAM access keys.
- The keys were rotated through an AWS management identity, the old key was
  deleted, and the application was restarted.
- A post-rotation smoke test uploaded, verified, and deleted a 117,182-byte
  object successfully. Rotation is complete.

## Recommended sequence

1. Decide whether outbound application email will be restored soon.
2. If yes, replace legacy SendGrid credentials with a restricted key and test
   the exact required mail flow. If no, remove the unused paid add-on after
   preserving any account-level evidence the user needs.
