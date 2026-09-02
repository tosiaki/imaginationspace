# Crawler-load snapshot — 2026-09-02

This is a bounded snapshot of raw Heroku router log entries, not an estimate
from Ahoy, application analytics, or another lossy aggregation. The Heroku log
request was capped at 1,500 lines, so this report describes only the parsed
window and must not be treated as a full-day traffic total.

## Raw window

- UTC interval: 2026-09-02 13:06:35 through 13:09:16
- Window length: 161 seconds
- Parsed router requests: 1,496
- Observed request rate: 9.29 requests/second
- Distinct `fwd` values: 1,450
- Methods: 1,495 GET and 1 HEAD
- Status: 1,496 responses with 301
- Total router-reported response bytes: 0
- Service time: p50 1 ms, p95 1 ms, p99 2 ms, maximum 9 ms
- Threshold-triggered application load diagnostics: 0

The `fwd` field is router-supplied request metadata. Distinct values show that
per-address application rate limiting would have little effect in this window,
but they are not proof of 1,450 independent people or machines.

## Requested routes

- `/articles`: 1,237 requests
- `/users/263`: 235 requests
- `/`: 24 requests

The legacy requests predominantly contained large permutations of tag query
parameters. Those parameters no longer reach content controllers or database
queries: every sampled request received the redirect-only response.

## Requested hosts

- `www.windyfall.com`: 1,249 requests
- `www.imaginationspace.org`: 196 requests
- `www.fancomics.org`: 51 requests

All three names remain configured as Heroku custom domains. Removing an old
custom domain would prevent Heroku from routing that hostname to this app only
after its DNS is also changed or removed. That is a product/domain decision,
not a safe inference from this short traffic window.

## Interpretation

The redirect mitigation has eliminated the expensive behavior that prompted
the crawler work: this sample performed no content-controller queries, emitted
no response bodies, and completed at p95 1 ms. The remaining cost is request
arrival at the Heroku router and web dyno itself. Additional application-level
branching or IP rate limiting is unlikely to materially improve this pattern.

Further reduction requires one of the following semantic or infrastructure
changes:

1. Retire obsolete custom domains at both DNS and Heroku.
2. Return 404/410 for retired legacy URLs instead of redirecting them.
3. Put an edge/cache service in front of the dyno.

The first two require an explicit product choice; the third adds a third-party
service and remains outside the current preference.

## Domain retirement follow-up

`www.imaginationspace.org` and `www.fancomics.org` were subsequently removed
manually. Heroku now lists only `www.windyfall.com` as a custom domain. Live
HTTP resolution checks could no longer reach either retired hostname, although
one local DNS query briefly returned the old `www.imaginationspace.org` CNAME,
consistent with resolver-cache propagation.

A second raw 1,496-request window around the removal observed 7.92 requests per
second: 1,363 for `www.windyfall.com`, 103 for `www.imaginationspace.org`, and
30 for `www.fancomics.org`. Because this bounded window overlaps propagation,
it is not evidence that the retired names remain routed after the live checks.
