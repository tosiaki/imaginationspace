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

- `SENDGRID_API_KEY` is now present and authenticates successfully.
- The key has `mail.send` scope and does not have `verified_senders.read` scope.
- Authentication-only SMTP negotiation succeeded; no test message was sent.
- `SENDGRID_USERNAME` and `SENDGRID_PASSWORD` have been removed.
- Repository history confirms those legacy names were introduced as the 2018
  Heroku SendGrid add-on's plain-auth SMTP username and password. The deleted
  password's internal format cannot be proven after deletion. A retained 2021
  SendGrid notice states that API keys and account 2FA had become mandatory,
  and mail continued working afterward. Operationally, this makes it likely
  that the credential stored under the legacy variable name had already been
  migrated to an API key even though the application did not adopt the modern
  fixed `apikey` username convention until 2026.
- Password recovery and confirmation are restored with generic anti-enumeration
  responses, five-request/30-minute mail-trigger limits, uncached lightweight
  pages, and six-hour password-reset tokens. Signup and notification mail remain
  retired.
- The default sender is now `do-not-reply@windyfall.com`. Because this key lacks
  sender-read permission, sender/domain verification must be confirmed in the
  SendGrid dashboard or by a controlled delivery test.
- A controlled production password-reset test delivered successfully and the
  complete password-change flow was confirmed. SendGrid domain authentication
  remains in progress while the new DNS host records propagate.

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

1. Confirm `windyfall.com` domain authentication in SendGrid after DNS
   propagation completes.
