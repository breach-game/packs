# BREACH community packs

Missions written by players for [BREACH](https://github.com/breach-game/breach), the cybersecurity thriller that runs in your browser. Every pack here is reviewed, checked by CI, then published to a signed catalogue that the game reads under **Community missions** on its title screen.

**Play:** https://breach-game.github.io/breach/ (title screen, then *Community missions*)
**Write your own:** read [CONTRIBUTING.md](CONTRIBUTING.md), the complete guide, then [docs/workflow.md](docs/workflow.md) for how to push it and what happens next.

## What a pack is

A pack is a folder of YAML files. It holds data only, never code: a fictional network (a *world* pack), a mission played in a world (a *mission* pack), missions played in a row (a *series*), or an order through existing missions (a *path*). The game's engine simulates every command on that data. Nothing a pack says can reach a real machine.

```
packs/
  example.pixel-world/        a world: hosts, web pages, DNS, characters
  example.forgotten-backup/   a mission in that world: objectives, flag, rules, hints, debrief
  example.closing-the-door/   a defence mission: a question, a file to repair, `verify`
  example.atelier-pixel/      a series: the two missions above, played in a row in one save
  example.order-tracking/     author kit: a form, a role cookie, jq
  example.printer-farm/       author kit: a message broker, a decision with no wrong answer
  example.night-shift/        author kit: a detection rule, an agent guardrail, a code review
  premiers-pas.*/             first steps: a small bakery world and two one-technique missions
  dossiers.<name>*/           a case file: a world, three or four missions and their series
  hors-serie.<name>*/         a side series: a fictional world and its missions
  defis.*/                    the challenges: one world and six missions played at Expert only
  paths.<name>/               a path: an order through official and community missions
```

## Paths

A path is a pack that only lists steps through missions that already exist, official or from this repository, with a sentence on why each one matters. The store shows them first, with the player's progress.

| Folder | Path | Steps |
| --- | --- | --- |
| `paths.owasp-web` | Web flaws | 9: from a chatty form to the OWASP Top 10 of season 3 and two real cases |
| `paths.owasp-llm` | Attacking and defending an AI | 12: the OWASP Top 10 for LLM applications, campaign, season 5 and case files |
| `paths.soc` | SOC analyst | 11: from reading a log to the finale, all on the defence side |
| `paths.first-steps` | First steps | 9: for someone who has never opened a terminal, one technique per step, up to the campaign |

## First steps

Short standalone missions at difficulty 1, in a small fictional bakery (`premiers-pas.fournil-world`), each teaching a single technique.

| Folder | Mission | What you learn |
| --- | --- | --- |
| `premiers-pas.orphan-subdomain` | The orphan subdomain | A DNS name that still points to a deleted cloud bucket, proving it can be taken over, removing the record |
| `premiers-pas.factory-pin` | The factory code | A connected oven still on the code from its manual, one proof and no click, a code per device and a page kept on the local network |

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
| 11 | `dossiers.linotte*` | The open tap | "LLMjacking", described by Sysdig, 2024 | Unbounded consumption: reading a bill like a log, a forgotten key with no limit, ceilings and alerts on a paid AI model |
| 12 | `dossiers.roitelet*` | The planted sentence | Tay, Microsoft's conversational program, 2016 | Data poisoning: an assistant that learns from every visitor and serves it to all the others, review before use, a memory one can trace and roll back |
| 13 | `dossiers.bergeronnette*` | The diagnostic file | Okta support system, 2023 | A browser diagnostic file (HAR) is a key, a session replayed from elsewhere and the rule that sees it, cleaning files on arrival and binding sessions to their device |
| 14 | `dossiers.rouge-gorge*` | The freeze | A Replit coding agent, 2025 | Watching an agent live and stopping it with the cheapest move, a guardrail outside the model, separating production from the agent's playground and testing restores |
| 15 | `dossiers.chardonneret*` | The assistant's answer | Air Canada's chatbot ruling, 2024 | A chat assistant that makes up rules confidently, a company answering for its assistant, grounding answers in published pages and handing over when unsure |
| 16 | `dossiers.sittelle*` | Somebody else's script | The Polyfill script service, 2024 | A third-party script that changes owner and content, serving a different file to phones, counting diverted visitors in DNS, self-hosting with Subresource Integrity and a strict CSP |
| 17 | `dossiers.bouvreuil*` | What gets pasted | Samsung engineers and a public AI assistant, 2023 | Pasting into a public assistant is sending, a rule on upload size, an egress filter that reads labels, an internal assistant and training rather than a ban |
| 18 | `dossiers.verdier*` | The key at home | LastPass, 2022 | What an encrypted backup leaves in clear, withdrawing a stolen key rather than blocking an address, keeping backup keys apart and usable from managed devices only, telling customers what to change |
| 19 | `dossiers.loriot*` | The tag that moved | tj-actions/changed-files (CVE-2025-30066), 2025 | Secrets printed in a public CI log and encoded twice, pinning a third-party action to a full commit hash, a read-only job token, rotating what leaked and telling the library's users |
| 20 | `dossiers.mouette*` | The forgotten patch | Equifax, 2017 | Finding a forgotten component with a software bill of materials, an inspection device blinded by an expired certificate, knowing what you own and who gets the alert |
| 21 | `dossiers.cormoran*` | Twelve hundred cousins | 23andMe, 2023 | Credential stuffing seen with a threshold rule counted by client rather than address, a sharing feature that multiplies a leak, a required second step and telling every exposed person |
| 22 | `dossiers.pluvier*` | The living-room password | Snowflake customers, 2024 | Reading a spyware archive with `unzip`, revoking a stolen credential rather than blocking an address, keys, allowed networks and managed devices for contractors |
| 23 | `dossiers.gobemouche*` | The director's face | Arup, 2024 | Reading a transfer request's headers with `mailhdr`, calling back a directory number with `call` rather than the one in the request, two signatures and no "confidential" exception |
| 24 | `dossiers.huppe*` | The Friday of the counters | CrowdStrike, 2024 | No attacker: finding a faulty content file in a rescue-mode journal (`journalctl`, `last`, `strings`), why withdrawing it repairs nothing, the recovery order traced with `path` (key vault before counters), delivery rings set with `flag` |
| 25 | `dossiers.heron*` | The remote lookup | Log4Shell (CVE-2021-44228), 2021 | Defence only: finding a library hidden inside a vendor archive (`sbom`, `unzip -l`), egress blocking while no patch exists, a first fix that is not enough, a rule on the lookup class, finding a miner with `ps` and `ss`, rebuilding rather than cleaning |
| 26 | `dossiers.rossignol*` | The heartbeat | Heartbleed (CVE-2014-0160), 2014 | Defence only: counting affected services from `nmap -sV` banners (older branches are safe), patching and switching the heartbeat off on a box that cannot be updated, a rule on the new IDS signature and what it cannot prove, reissuing keys and certificates, the order of the message to users |
| 27 | `dossiers.engoulevent*` | The extra page | MOVEit Transfer (CVE-2023-34362), 2023 | Defence only: the page and the admin account an intruder left, found against the vendor manifest, a rule on the exact path, removing them with the patch, counting clients and people from an audit log, a provider's duty to tell its clients, the ransom decision |
| 28 | `dossiers.becasse*` | The consumer key | Storm-0558 forged mail tokens, 2023 | Defence only, from the customer's seat: a rule on an application id nobody registered, reading a token with `jwt decode` (a consumer key accepted for an organisation), blocking the app rather than resetting passwords, counting mailboxes, a key past its retirement date read with `jq`, why only the detailed access log showed it |
| 29 | `dossiers.grimpereau*` | The signed update | SolarWinds Orion supply chain compromise, 2020 | Defence only, from a customer's seat: checking the installed build against the vendor's advisory, `strings` on a signed library, a DNS rule on the beacon domain, isolating the monitoring server, why a valid signature proves nothing about the code, the one CNAME answer that opened a second stage, the service account's night sign-in read with `last` |
| 30 | `dossiers.etourneau*` | The swarm of cameras | Mirai IoT botnet and the Dyn DNS attack, 2016 | Defence only, from a small customer's seat: an abuse notice, `flows` on the telnet port, a flow rule on cameras scanning the Internet (not the contractor on site), closing port forwards, why a reboot is not enough with factory passwords, the control address and the flood read in an exported flow log, deciding the cameras' future |

## Side series

Fictional stories with no real incident behind them, each a short series in its own small world (`hors-serie.*`).

| Folder | Series | What you learn |
| --- | --- | --- |
| `hors-serie.sosie*` | The look-alike domain | A fake invoice that passes SPF, DKIM and DMARC for its own look-alike name, hardening your real domain from the DMARC reports, shrinking what your website tells fraudsters |
| `hors-serie.vendredi*` | The Friday patch | Triaging a fictional advisory with `sbom --vuln` by exposure, finding why production still runs the old version (a stale cache, checked with `openssl dgst`), and a patch policy that `verify` can check |
| `hors-serie.coffre*` | The Vault | Recognising unsalted fast hashes with `hashid` and why one shared password shows up at once (`openssl dgst`, `grep -c`), decoding a guessable reset token with `base64 -d`, migrating to Argon2id and wrapping old hashes |
| `hors-serie.poste42*` | Bench 42 | Defence: reading what a workstation runs with `ps`, `ss`, `systemctl` and `journalctl`, why killing a process restarted by a service does nothing, a DNS fallback channel found with `flows` and a precise rule, then the week rebuilt with `timeline` and the data path traced with `path` |
| `hors-serie.mardi*` | Black Tuesday | No attacker: reading a crash in `journalctl`, choosing the smallest reversible move (`flag` rather than `rollback`), finding the last backup that really holds data with `tar -tzvf` when the script swallowed rsync's error, then a timeline, a clean release with `deploy` then `flag`, and what to tell customers |
| `hors-serie.orchestre*` | Orchestra | A Kubernetes audit in read-only: a dashboard left open hands out a kubeconfig, `kubectl get` and `describe` show a licence key in a pod's environment and a privileged debug pod mounting the node, then fixing the manifests (secret reference, no privileged pod, sign-in back) checked by `verify` |
| `hors-serie.appli*` | The App | A mobile app audit without a phone: the package is a zip anyone can fetch, `unzip` and `jq` find a partner key in its configuration, `strings` on `classes.dex` finds a staff route and the header the app sets itself, then fixing the next build (`verify`), deploying the API that checks the role from the session, and rotating the shipped key |
| `hors-serie.ia-fantome*` | Shadow AI | AI governance on the defence side: counting uploads to outside AI services in the gateway log with `grep`, `cut`, `sort`, `uniq` and `wc`, a gateway guardrail judged by `eval run` that stops personal data and nothing else, then a downloaded model whose card says safetensors but `strings` shows a pickle, removed before its first load, and the EU AI Act's view of sorting CVs |
| `hors-serie.annuaire*` | The Directory | Identity hygiene on the defence side: an anonymous `ldapsearch` shows a password in a description and a former contractor still admin, then closing anonymous access; a live password spray caught with a counting rule (`count|gte`, `by: src`) and the account cut off; then `last`, `journalctl`, a `path` and a `timeline`, the admins group reviewed with `verify`, and one account per app |

A mission can also be played in an official world, NovaMind (`requires: [breach.world.novamind]`) or the world of a season (`breach.world.pelican`, `breach.world.verdure`…), using the hosts, pages and characters it already has.

## Challenges

Six short missions in one fictional world (Polygone Services), each set to `levels: [expert]`: no instruction from Ada, no hint, only the briefing and the objectives. The store files them under Challenges. A challenge needs no `guide` table.

| Folder | Challenge | What it asks |
| --- | --- | --- |
| `defis.bonne-ligne` | The right line | Find the one real download of a customer export in a noisy access log (`grep`, `cut`, `sort -u`, `wc -l`) |
| `defis.facture-voisine` | The invoice next door | Read the witness account's invoice through an API that only checks you are signed in |
| `defis.trois-couches` | Three layers | Read an unknown program and its certificate without running them (`strings`, `base64 -d`, `openssl x509`) |
| `defis.trois-lignes` | Three lines | Point out the three faulty lines of a pull request with `review`, every mistake costs points |
| `defis.pluie-fine` | Fine rain | Password guessing from twelve addresses: write the rule that counts by account and ignores a colleague's typos |
| `defis.garde-fou` | The guardrail | Write a support agent's refund guardrail that holds on both sides of a threshold (`eval run`) |

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
