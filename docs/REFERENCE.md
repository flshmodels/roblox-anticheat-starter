# Roblox Anti-Cheat Starter Kit

A small set of server-side building blocks for Roblox games. It helps developers limit remote spam, validate basic input, and detect use of a decoy remote. It is free to use under the MIT License.

This is a starter kit, not a plug-and-play shield. **It cannot detect every cheat or reliably determine whether a player injected software.** It does not currently detect speed, flying, teleporting, impossible rewards, or aimbots. Those checks depend on your game and need their own server-side rules.

## What it does

- **RateLimiter** limits requests per player and action. It drops excess requests; a rate limit alone is not proof of cheating.
- **Validation** checks bounded strings and finite numbers. Your game must also check permissions, context, distance, and server-owned state.
- **Guard** watches a decoy RemoteEvent. If a player fires it, the server can log, kick, or issue a temporary experience ban. Start with logging and make sure no legitimate code uses the decoy.

## Setup in Studio

1. Create a folder called `AntiCheat` in `ServerScriptService`. Add ModuleScripts called `RateLimiter`, `Validation`, and `Guard`; copy in the matching files from `src`.
2. In `ReplicatedStorage`, create RemoteEvents named `ExampleAction` and `DecoyRemote`. Never use `DecoyRemote` in legitimate gameplay.
3. Add a Script in `ServerScriptService` using `examples/Example.server.luau`. Run a multiplayer test and inspect Output. The example does not grant items or perform game actions.
4. Adapt the action handler to verify server-owned permissions and game state. Make a separate limiter for each action and remove its player state when a player leaves.

## Inputs and outputs

`RateLimiter.new(capacity, refillPerSecond, clock?)` creates a token bucket. Capacity is the permitted burst, refill is tokens restored per second, and the optional clock supports tests. `limiter:allow(userId)` returns a boolean and consumes a token on success; `limiter:remove(userId)` clears that user's bucket.

`Validation.numberInRange(value, min, max)` returns true only for a finite number within the inclusive range. `Validation.shortString(value, maxBytes)` returns true for a nonempty string within the byte limit. They do not check content, permissions, or game state.

`Guard.watchHoneypot(remote, options)` returns an event connection. Options are `action` (`log`, `kick`, or `ban`), optional `onDetection(player, reason)`, and `banSeconds` (required positive whole seconds for `ban`). Logging calls the callback if supplied; use the example callback to see detections in Output. Disconnect the returned connection when no longer needed.

Bans use Roblox's `Players:BanAsync` for this experience and explicitly exclude suspected alternate accounts. Enable the Ban API for the experience, provide an appeal route, and test in a suitable published test experience before enabling bans. A failed ban is reported in server Output. A kick only removes the player from their current server.

## Testing and limits

Run `lune run tests/run` to check the pure modules. GitHub Actions runs these tests on pushes and pull requests. Studio multiplayer and Ban API behavior require separate testing in Roblox; automated unit tests do not prove live behavior. For a first live test, keep the action set to `log`, fire the decoy only from a test client, and confirm normal gameplay never touches it. A legitimate client firing the decoy will trigger enforcement, so do not enable bans until you have verified your integration.

See [Roblox's client-server security guide](https://create.roblox.com/docs/scripting/security/client-server-boundary), [detection guidance](https://create.roblox.com/docs/scripting/security/server-side-detection), and [Ban API reference](https://create.roblox.com/docs/reference/engine/classes/Players#BanAsync).
