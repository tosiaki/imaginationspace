# WindyFall architecture and reference-study plan

## Decision

Build WindyFall as a Svelte 5 application hosted by Rails, with a pure
JavaScript simulation core that does not import Svelte, touch the DOM, or call
Rails directly. Do not build the game through manual DOM manipulation.

The repository already compiles Svelte through Shakapacker. A game UI has many
simultaneously changing projections of the same state: resources, action
timers, travel, map discovery, workers, construction, logistics, story state,
and unlock notifications. Declarative Svelte components are a better fit than
manually keeping those views synchronized. Keeping the simulation independent
of Svelte preserves deterministic testing and leaves open a later renderer or
server-side simulation.

## Boundaries

The initial client should have four explicit layers:

1. **Content definitions** — versioned data for resources, locations, actions,
   buildings, discoveries, events, and story fragments.
2. **Simulation core** — deterministic state transitions and elapsed-time
   processing. Inputs are commands plus time; outputs are new state plus domain
   events.
3. **Persistence adapter** — initially IndexedDB with export/import and schema
   migrations. Later, an authenticated Rails adapter stores snapshots and an
   append-only command/event journal.
4. **Svelte presentation** — components subscribe to projections, dispatch
   commands, and never mutate game state directly.

Use a seeded pseudo-random generator whose state is saved. Time-dependent
results must be calculated from explicit timestamps and capped elapsed-time
windows, not from an always-running browser timer. The UI clock may animate,
but only commands and simulation ticks change authoritative state.

## Persistence phases

### Initial development

- IndexedDB, not `localStorage`, for authoritative saves.
- Versioned save envelope containing schema version, content version, world
  seed, PRNG state, last processed timestamp, and simulation state.
- Atomic write to a new revision before replacing the current pointer.
- Manual JSON export/import from the first playable build.
- A bounded local event journal for debugging and pacing studies.

### Server persistence

- Rails owns player identity, save ownership, optimistic revision numbers, and
  durable snapshots.
- Upload commands/events in batches and periodically compact them into a new
  snapshot; keep enough journal history to diagnose progression bugs.
- Validate commands and elapsed-time bounds server-side before accepting a
  revision. Client state must not become trusted merely because it was saved.
- Avoid tying core state to Rails models one mechanic at a time. Store a
  versioned game-state document plus indexed metadata needed for lookup and
  operations.

## First vertical slice

Build one small but complete loop before the full map:

1. Wake in a wind-battered shelter.
2. Gather two local resources with active actions.
3. Stabilize warmth and shelter through idle production/consumption.
4. Scout a neighboring map cell and encounter a choice with a persistent
   consequence.
5. Construct one spatial building on a chosen cell.
6. Unlock one genuinely new mechanic, such as wind routing or expedition
   planning, rather than only a stronger version of an existing action.
7. Save, close, reopen, and reconcile bounded offline progress.

This slice must include domain events and instrumentation so pacing can be
measured from the first prototype.

## Long-term design constraints

- Progression should alternate quantitative improvement with qualitative
  mechanic unlocks.
- Maps need optional sites, hazards, characters, puzzles, renewable activities,
  and reasons to revisit—not only traversal gates.
- Lore should be layered: environmental clues, conflicting accounts, character
  arcs, and discoveries that alter mechanical choices.
- Camps remain spatial. Building placement should interact with terrain,
  adjacency, wind exposure, routes, and local capacity.
- Logistics remain physical. Camps have local inventories; transfers use
  routes, carriers, travel time, capacity, risk, and scheduling. Later unlocks
  reduce coordination work without collapsing all storage into one pool.
- Trade should support specialization, route investment, scarcity response,
  diplomacy, contracts, and otherwise inaccessible capabilities.
- Endgame must be extensible through additional regions and systems without
  invalidating existing saves or relying on exponential number inflation.

## Studying Level 13 gameplay

The source checkout is reference evidence, not WindyFall implementation code.
Static source inspection can reveal rules but cannot establish felt pacing,
decision pressure, idle cadence, or which discoveries are memorable.

The checked-out Level 13 version 0.7.1 provides an initial static baseline: 361
distinct action IDs across its action-data sections, 327 explicit requirement
entries, 28 actions with explicit durations ranging from 1 to 600 seconds, 119
upgrade entries, eight milestones, and eight story arcs containing 65 segments.
These counts describe implementation breadth, not quality or pacing, and should
be compared with observed play rather than used as WindyFall content targets.

Run the local study server from this repository:

```powershell
py -3 script\serve_level13_study.py --level13 G:\level13
```

Then open `http://127.0.0.1:8130/`. This is required because Level 13 uses XHR
and RequireJS resources that do not work correctly from a `file:///` URL. The
server leaves the checkout unchanged, removes upstream analytics/error scripts
from the served HTML, and injects the local observer.

The observer records raw timestamped UI clicks and native game signals,
including actions, movement, camps, upgrades, feature unlocks, milestones,
story flags, fights, and caravans. It also records a state snapshot every minute
and at major transitions. Data remains in browser local storage until exported:

```javascript
WindyFallLevel13Study.download()
```

Keep Level 13's own exported save alongside each observation export. The save
is the reconstructable raw state; the observer log supplies the event ordering
and wall-clock cadence that a save alone lacks.

For each play session, separately note subjective evidence that telemetry
cannot answer: current goal, meaningful choices, uncertainty, excitement,
friction, periods of waiting, why the session ended, and what the player
expected to unlock next. Review by progression interval rather than only whole
run totals:

- first 15 minutes
- first active hour
- first return after offline progress
- each new camp/region
- each milestone or mechanic unlock
- midgame routine
- approach to the current ending

Useful derived measures include time between qualitative unlocks, active versus
idle time, repeated-action concentration, travel/backtracking share, failed
expeditions, inventory overflow, trade frequency and purpose, construction
choices, map cells revisited, lore events per hour, and gaps where the player
has no meaningful decision. Derive these from exported raw events and saves;
do not treat aggregate counters alone as sufficient evidence.
