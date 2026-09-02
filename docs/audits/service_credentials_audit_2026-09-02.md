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

The failure is therefore stale provider/add-on state rather than the Redis 6
URL parser. Action Cable and the three legacy Redis namespaces are currently
nonfunctional if invoked. Because the endpoint cannot be reached, the raw key
inventory could not be inspected. The add-on must not be destroyed or replaced
until the user decides whether its inaccessible legacy data needs provider-side
recovery.

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
- Rotation therefore requires an AWS management identity or console session.

## Recommended sequence

1. Use an AWS management identity to rotate the application credentials, then
   immediately repeat the authenticated upload smoke test.
3. Decide whether outbound application email will be restored soon.
4. If yes, replace legacy SendGrid credentials with a restricted key and test
   the exact required mail flow. If no, remove the unused paid add-on after
   preserving any account-level evidence the user needs.
5. Ask Redis Cloud whether the stale endpoint/database can be recovered. Only
   then decide between credential rotation, replacement, or removing Redis and
   its currently inactive application integrations.
