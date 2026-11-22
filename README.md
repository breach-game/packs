# BREACH community packs

Missions written by players for [BREACH](https://github.com/breach-game/breach), the cybersecurity thriller that runs in your browser. Every pack here is reviewed, checked by CI, then published to a signed catalogue that the game reads under **Community missions** on its title screen.

**Play:** https://breach-game.github.io/breach/ (title screen, then *Community missions*)
**Write your own:** read [CONTRIBUTING.md](CONTRIBUTING.md), the complete guide, then [docs/workflow.md](docs/workflow.md) for how to push it and what happens next.

## What a pack is

A pack is a folder of YAML files. It holds data only, never code: a fictional network (a *world* pack) or a mission played in a world (a *mission* pack). The game's engine simulates every command on that data. Nothing a pack says can reach a real machine.

```
packs/
  example.pixel-world/        a world: hosts, web pages, DNS, characters
  example.forgotten-backup/   a mission in that world: objectives, flag, rules, hints, debrief
```

A mission can also be played in the official NovaMind world (`requires: [breach.world.novamind]`), using the hosts, pages and characters it already has.

## The rules every pack follows

1. **No real target.** Reserved domains only (`*.test`, `*.example`, `example.com`…) and private or documentation addresses (`10.0.0.0/8`, `192.168.0.0/16`, `192.0.2.0/24`…). The validator refuses anything else.
2. **Classes of weaknesses, not exploits.** A mission illustrates a known category (OWASP Top 10, OWASP Top 10 for LLM applications). Nothing in it works as-is against a real system.
3. **Always under a mandate.** The player tests with written authorisation, and the story says so.
4. **Every attack has its defence.** A mission ends with a debrief that explains how to prevent what the player just did.
5. **For players aged 16 and over.** Thriller tone, humour welcome, no violence, nothing shocking.
6. **Success is deterministic.** Flags are checked by the engine, never by a language model.

## How a pack gets to players

1. You open a pull request that adds a folder under `packs/`.
2. CI runs the game's own validator on it: schema, safety rules, translations, and a replay of your `solution.txt` in every language you declare. A mission that cannot be finished with its solution does not pass.
3. A maintainer reviews the story, the tone and the lesson.
4. Once merged, the publishing workflow compiles the packs, writes `index.json` and signs it. The game checks that signature with a key built into it, then checks each pack against the SHA-256 listed in the catalogue, before reading a single line.

CI also runs every night against the latest game engine, so a pack that a change in the game would break is caught early.

## Repository layout

| Path | Role |
| --- | --- |
| `packs/` | one folder per pack |
| `.github/workflows/check.yml` | validation and solution replay, on every pull request |
| `.github/workflows/publish.yml` | build, sign and publish the catalogue on GitHub Pages, after a merge |
| `CONTRIBUTING.md` | how to write and test a pack |
| `docs/workflow.md` | how to push a pack, what CI and publishing do, updates and withdrawals |

The published site contains only data: `index.json`, `index.json.sig` and the `.breachpack` files.

## Licence

MIT, see [LICENSE](LICENSE). By opening a pull request you agree that your pack is published under it.
