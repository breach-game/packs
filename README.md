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
  example.closing-the-door/   a defence mission: a question, a file to repair, `verify`
  example.atelier-pixel/      a series: the two missions above, played in a row in one save
  dossiers.<name>*/           a case file: a world, three or four missions and their series
```

## The case files

A case file ("Dossier") is a short series inspired by a real, publicly documented incident. The company in the story is fictional, the player works under a mandate, and the last debrief ends with a sourced card of what really happened.

| # | Folder | Series | Inspired by | What you learn |
| --- | --- | --- | --- | --- |
| 01 | `dossiers.covera*` | The trusted script | Codecov, 2021 | Secrets left in image layers, a script piped into a shell, rotating what leaked |
| 02 | `dossiers.brindille*` | The agent that helps too much | Invariant Labs research on AI agents and GitHub, 2025 | Indirect prompt injection, the "toxic flow" of an agent, least privilege for tools |
| 03 | `dossiers.pinson*` | The phone call | Twitter, 2020 | Pretexting, a look-alike sign-in page, why one fooled person must not be enough |
| 04 | `dossiers.martinet*` | The "Approve" button | Uber, 2022 | MFA fatigue, a secret in a shared file, fixing the system rather than blaming the person |
| 05 | `dossiers.mesange*` | The role that was too wide | Capital One, 2019 | A relay that fetches too much, cloud roles and least privilege |
| 06 | `dossiers.sorbier*` | Half a second too long | xz Utils, 2024 | Reading a slowdown, a release archive that differs from the repository, going back to a safe version |
| 07 | `dossiers.fauvette*` | Without a click | EchoLeak (CVE-2025-32711), 2025 | Zero-click indirect injection in an assistant, keeping outside content apart from inside data |
| 08 | `dossiers.alouette*` | The one-euro car | A car dealership's chatbot, 2023 | A general-purpose model as a sales assistant, limits on what it may promise |
| 09 | `dossiers.grive*` | One line too many | CVE-2025-53107, 2025 | Command injection in a tool server for AI agents, arguments instead of a shell line |
| 10 | `dossiers.hirondelle*` | One number away | First American Financial, 2019 | Broken access control: a document link that is a counter in disguise, the server check that was missing, following a finding until it is fixed |

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

## Community

Everyone taking part follows the [Code of Conduct](https://github.com/breach-game/.github/blob/main/CODE_OF_CONDUCT.md). A pack that targets real people or systems is removed from the catalogue at once. Security problems go through [private reporting](https://github.com/breach-game/packs/security/advisories/new), never a public issue.

## Licence

MIT, see [LICENSE](LICENSE). By opening a pull request you agree that your pack is published under it.
