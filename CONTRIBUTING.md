# Writing a BREACH mission

This guide takes you from an empty folder to a mission published in the game. The two packs in `packs/` are a complete, working example: keep them open while you read.

- [1. Before you start](#1-before-you-start)
- [2. Set up](#2-set-up)
- [3. Anatomy of a pack](#3-anatomy-of-a-pack)
- [4. The world](#4-the-world)
- [5. The mission](#5-the-mission)
- [6. Rules: events, conditions, effects](#6-rules-events-conditions-effects)
- [7. Guiding the player: Ada, guidance levels, hints](#7-guiding-the-player-ada-guidance-levels-hints)
- [8. Characters](#8-characters)
- [9. Texts and translations](#9-texts-and-translations)
- [10. Test your mission](#10-test-your-mission)
- [11. Submit it](#11-submit-it)
- [12. The defence side](#12-the-defence-side)
- [13. Reference](#13-reference)

## 1. Before you start

BREACH teaches cybersecurity by letting the player attack a fictional company under a signed mandate, then showing how to defend. A good mission:

- teaches **one class of weakness** (an exposed backup, a secret in Git history, a prompt injection, a chatty support agent…), linked to OWASP Top 10 or OWASP Top 10 for LLM applications;
- lasts 10 to 20 minutes and is winnable with the in-game commands, without outside knowledge;
- ends with a **debrief** that says what the defenders should have done;
- reads like a thriller with a light touch, for players aged 16 and over.

What a pack can never contain:

- a real target: domains must be reserved (`.test`, `.example`, `.invalid`, `.localhost`, `example.com/net/org`), addresses private or reserved for documentation (`10/8`, `172.16/12`, `192.168/16`, `192.0.2/24`, `198.51.100/24`, `203.0.113/24`, `127/8`). A link to a learning site such as `owasp.org` is allowed as a reference;
- a working exploit, a real payload or a real vulnerability identifier that could be reused as-is;
- code: no script, no HTML of your own on pages (the game draws pages from blocks), no control characters or terminal escape sequences;
- a story where the player acts without authorisation. Going out of scope is refused by the game, with a reminder of the law.

The validator enforces the technical part. The review enforces the rest.

Everyone taking part, in pull requests, reviews and issues, follows the [Code of Conduct](https://github.com/breach-game/.github/blob/main/CODE_OF_CONDUCT.md).

## 2. Set up

You need Node.js 22 or later, pnpm 10 and Git. Clone this repository and the game side by side:

```bash
git clone https://github.com/breach-game/packs.git
git clone https://github.com/breach-game/breach.git
cd breach && pnpm install && cd ..
```

The validator lives in the game repository, so the packs are always checked by the very code that will load them. From the `breach` folder:

```bash
# Validate every pack and replay every solution
pnpm --silent --filter @breach/pack-cli run cli check "$PWD/../packs/packs" --community --with "$PWD/content"

# Print the full transcript of one mission's solution, in English or French
pnpm --silent --filter @breach/pack-cli run cli play "$PWD/../packs/packs" example.forgotten-backup en --with "$PWD/content"
```

`--with content` makes the official packs available, so that a mission can be played in the NovaMind world. Use absolute paths, as above.

## 3. Anatomy of a pack

```
packs/your-name.mission-name/
  pack.yaml        identity: id, version, title, authors, languages
  mission.yaml     a mission pack (or world.yaml for a world pack)
  i18n/en.yaml     texts in English
  i18n/fr.yaml     texts in French
  solution.txt     the commands that finish the mission (mission packs only)
  files/…          optional: long texts pulled in with { $file: files/name.txt }
```

`pack.yaml`:

```yaml
id: jdoe.lost-backup            # <your-name>.<pack-name>, lowercase. "breach." is reserved.
version: 1.0.0                  # change it every time you change the pack
engine: ">=0.2 <1"              # engine versions this pack works with
kind: mission                   # or world, or series (section 5)
requires: [jdoe.bakery-world]   # a mission names its world first
title: { fr: La sauvegarde perdue, en: The lost backup }
summary: { fr: …, en: … }       # one sentence, shown in the mission list
authors: [Jane Doe]
locales: [fr, en]               # one or both; players of another language see it as not yet translated
difficulty: 1                   # optional, 1 to 3, shown in the list
skills: [web, defense]          # optional, up to 4 of: recon, web, social, llm, logs, linux, crypto, supply, defense
```

Use your GitHub login as the first part of the id, so that two authors never pick the same one.

A world can be the official one: `requires: [breach.world.novamind]`. Your mission then happens in NovaMind's network, with its hosts, pages and characters, and can redefine those characters. A mission cannot add machines or pages to a world: to tell a story somewhere else, write a world pack too.

## 4. The world

`world.yaml` describes a small fictional network. Read `packs/example.pixel-world/world.yaml` alongside this section.

```yaml
startTime: "2026-12-07T09:30:00+01:00"   # in-game clock at the start
mandate: AP-2026-007                       # mandate number, shown at boot
scope:                                     # what the player may touch: everything else is refused
  domains: ["*.atelier-pixel.test"]
  networks: ["10.42.0.0/24"]
player: { host: kestrel, user: kestrel }   # the player's workstation (a host of kind: player)
resolver: 10.42.0.2
hosts: […]
dns: { atelier-pixel.test: { A: ["10.42.0.10"], MX: [mail.example.net], TXT: [...] } }
whois: { atelier-pixel.test: "Domain Name: …" }
noise: { … }                               # how much each command alarms the target
rules: [ … ]                               # rules active in every mission of this world
npcs: [ … ]                                # characters
```

**Hosts.** Each host has an `id` (used in rules), a `hostname`, an `ip`, a `kind` (`player`, `host`, `ai` or `unknown`, which sets its colour on the map), a position on the map (`map: { x, z, h }`, roughly −400 to 400), `links` to other hosts (lines on the map), and optionally:

- `services`: open ports for `nmap` (`{ port: 443, name: https, product: nginx 1.22 }`);
- `fs`: files, for the player's own machine. A string is a file, an object is a folder; `{ $t: key }` is a translated file, `{ $content: "…", $mode: "600" }` sets permissions;
- `web`: routes for `curl` and the in-game browser (below);
- `repos`: Git repositories that `git clone` can fetch, with their commits and diffs;
- `hidden: true`: the host does not answer scans until a rule reveals it.

**Web routes.** A route is a path with a `status`, `headers` and either a raw `body` (any text: a `robots.txt`, a JSON error, a directory listing) or a `page` made of blocks:

```yaml
web:
  "/":
    page:
      title: web.home.title
      blocks:
        - nav: [{ href: "/", label: web.nav.home }, { href: "/order", label: web.nav.order }]
        - h1: web.home.h1
        - p: web.home.p1
        - list: [web.home.item1, web.home.item2]
        - comment: web.home.comment     # only visible in the page source and in curl
        - chat: pixou                   # a live chat with a character
        - footer: web.footer
  "/robots.txt": { headers: { content-type: text/plain }, body: "User-agent: *\nDisallow: /old/\n" }
  "/order/chat": { status: 405, chat: pixou }   # curl -d "message" talks to the character here
```

Blocks are `h1`, `h2`, `p`, `list`, `code`, `nav`, `link`, `comment`, `chat` and `footer`. The game draws them itself and `curl` prints the HTML it derives from them. You never write HTML for a page.

**Noise.** Every command adds noise to a gauge. At 100 the target's SOC spots the player, who goes back to the last checkpoint. The world's table gives a cost per command, and per option:

```yaml
noise:
  nmap: { base: 18, flags: { "-sn": -10, "-A": 30, "-T5": 36 } }
  curl: 3
  dig: 0
```

A mission can override any entry with its own `noise` table.

## 5. The mission

`mission.yaml`, as in `packs/example.forgotten-backup/`:

```yaml
order: 0                  # position among the missions of the same world
stage: recon              # attack stage, shown in the notebook
briefing: fb.briefing

objectives:
  - { id: homepage, text: fb.obj.homepage }
  - { id: robots, text: fb.obj.robots }
  - { id: backup, text: fb.obj.backup }
  - { id: chat, text: fb.obj.chat, optional: true }    # bonus, not needed to finish

flags:
  - { id: admin-token, value: "FLAG{pixel-old-backup-7c2e}", points: 100, objective: backup }

reveal: [www]             # hosts shown on the map from the start
rules: [ … ]              # see section 6
guide: { … }              # see section 7
hints: { … }
debrief:
  title: fb.debrief.title
  lesson: fb.debrief.lesson
  points: [fb.debrief.p1, fb.debrief.p2, fb.debrief.p3]
  reference: "OWASP Top 10 · A05 Security Misconfiguration"
```

The mission is complete when every objective that is not optional is done. A flag is a string of the form `FLAG{…}` that the player finds in the world and sends with `submit FLAG{…}`: the right flag completes its objective. The build stores only its SHA-256.

**Score:** flag points, plus 50 per objective, plus the investigation answers, times the guidance level (×1, ×1.25, ×1.5), minus 10 per hint, 10 per wrong answer to a multiple choice question, 25 per detection and 3 per point of business impact. The defence replay adds its own points.

### More than flags: files, checks and questions

A mission where every step is "find the flag, submit it" gets dull. Three other tools, all used in `packs/example.closing-the-door/`:

```yaml
# Documents handed to the player when the mission starts, relative to the home directory.
files:
  atelier/site.conf: "server {\n    autoindex on;\n}\n"      # the text, a translation key, or { $file: files/site.conf }

# Things the player must repair. `verify` judges them and lists each one as OK or not.
checks:
  - id: listing
    text: cd.check.listing                                   # shown by verify
    if: { file: "~/atelier/site.conf", lacks: "autoindex on" }
  - id: old
    text: cd.check.old
    if: { file: "~/atelier/site.conf", contains: "deny all;" }
    objective: harden                                        # done when its checks and the guards (no objective) pass

# Multiple choice. Ada asks with the effect `ada.ask: leak`.
questions:
  - id: leak
    text: cd.q.leak
    objective: leak
    correct: rotate
    options:
      - { id: delete, text: cd.q.leak.delete, why: cd.q.leak.delete.why }   # why: shown when picked
      - { id: rotate, text: cd.q.leak.rotate }
      - { id: wait, text: cd.q.leak.wait, why: cd.q.leak.wait.why }
```

- **Repair.** The player changes a file with `edit <file>` (a small editor window), `sed -i`, or a redirection, then types `verify`. `~` is the home directory. Always add a check that the file still does its job (the example checks that the site is still served), otherwise deleting everything passes. An objective is done when all the checks that name it pass, together with the checks that name no objective (general guards).
- **Questions.** The options appear as buttons in the messenger, and `answer b` does the same in the terminal. The right option completes the objective. A wrong one costs 10 points and shows its `why`: write it as the explanation a mentor would give, that is where the player learns.
- **Short answers.** A flag does not have to look like `FLAG{…}`: `{ id: account, value: "c.morel", … }` lets the player `submit c.morel` (an address, a user name, a host). Keep them unambiguous.
- **Analysis.** With `files` and the text tools (`grep`, `cut`, `sort`, `uniq -c`, `diff`, `sha256sum`, `base64 -d`), a mission can be about reading a log, comparing two versions of a script, or decoding a value, with no network at all.

In `solution.txt`, answer with `answer <letter>` and repair with `sed -i`.

### Missions inspired by a real incident

A mission can replay a documented attack, as the case file in `packs/dossiers.covera*/` does. The rules:

- **Fictional names in the missions.** The company, its domain (reserved, as always) and its people are invented. The player stays a tester under a signed mandate who *emulates* the attacker: never the criminal.
- **The real story at the end.** The debrief of the last mission carries a `facts` card that names the real organisation and says what happened, and what differs from your fiction:

  ```yaml
  debrief:
    title: …
    lesson: …
    points: [ … ]
    facts:
      title: c3.facts.title                 # "What really happened: Codecov, 2021"
      points: [c3.facts.p1, c3.facts.p2]    # up to 8 texts
      sources:                              # 1 to 6, the only place where a real address is allowed
        - { label: "Codecov, post-mortem (2021)", url: "https://about.codecov.io/apr-2021-post-mortem/" }
  ```

- **Sourced facts only.** Every statement of the card must be in one of its sources. Prefer the organisation's own post-mortem, a regulator or a court document over press articles. The reviewer reads the sources.
- **Organisations, never private people.** Do not name an employee, a victim or a suspect, even when the press did.
- **A class of weakness, not a recipe.** The mission shows why it worked and how to defend. It never ships the real payload, a working exploit or a real tool. Proof of access is a harmless marker (a comment line), not the attacker's change.
- Sources are shown as plain text: the game follows no link.

### Series: several missions in a row

One long mission is tiring; a story in two or three short ones (the way in, the next step, the fix) works better. A **series** is a third kind of pack that lists missions of one world, as in `packs/example.atelier-pixel/`:

```yaml
# pack.yaml
id: jdoe.bakery-audit
version: 1.0.0
engine: ">=0.5 <1"
kind: series
requires: [jdoe.bakery-world]     # the world all its missions are played in
title: { fr: …, en: … }
summary: { fr: …, en: … }
authors: [Jane Doe]
locales: [fr, en]
```

```yaml
# series.yaml
missions:                          # 2 to 12, in playing order
  - jdoe.lost-backup
  - jdoe.closing-the-door
```

Each mission stays a pack of its own, with its own folder, `solution.txt` and debrief. In the game the series appears as one entry; the player goes from one mission to the next and can leave and come back. The whole series is **one save**: files the player changed, hosts found and variables set in a mission are still there in the next one. So:

- give the missions increasing `order` values, in the order listed;
- every mission must have the languages the series declares;
- CI replays the solutions one after the other in a single game, as the player will play them. A mission that only finishes when played alone fails the check.

Raise the series `version` when you change one of its missions in a way that breaks a game under way: the save is kept per series version.

## 6. Rules: events, conditions, effects

Everything the player does is an event. A rule waits for an event, optionally checks a condition, and applies effects. A rule fires once per mission, unless `once: false`.

```yaml
rules:
  - on: { event: HttpRequest, host: www, path: /robots.txt }
    do:
      - objective.complete: robots
      - ada.guide: { key: fb.ada.disallow, for: backup, step: 1 }
  - on: { event: DnsQuery, name: { glob: "*.atelier-pixel.test" }, found: true }
    if: { not: { objective: robots } }
    do:
      - ada.say: fb.ada.dns
```

Each field after `event` must match the event's field of the same name: a plain value matches exactly, `{ glob: "*.test" }` matches a pattern, `{ in: [a, b] }` one of a list, `{ contains: "text" }` a part of a text, `{ gte: 3 }` a number at least that big. The list of events and their fields is in the [reference](#13-reference).

## 7. Guiding the player: Ada, guidance levels, hints

Ada is the player's mentor. She speaks in three ways:

- `ada.say: key` is **story**. It is always shown, whatever the level.
- The `guide` table gives, for each objective that is not optional, **the sentence that starts it**. The engine says it as soon as that objective becomes the first open one and nothing else is pending. It is how a player is never left without a next step.
- `ada.guide: { key, for, step }` is a **finer step** inside an objective. It is dropped if that objective is already done or if a later step was already given, so a player who plays out of order never gets stale advice.

The player picks a level. **Guided**: Ada gives every command. **Autonomous**: if a key `<key>.standard` exists, Ada says that version instead, which gives the direction without the command; otherwise she stays silent. **Expert**: briefing and objectives only.

So for every guidance key, write the guided version (with the command between backquotes) and, when it makes sense, a `.standard` version without it:

```yaml
fb.ada.robots: "Websites publish a file for search engines: `curl https://www.atelier-pixel.test/robots.txt`."
fb.ada.robots.standard: "Websites also tell search engines what to skip: find that file."
```

`hints` gives up to three hints per objective, from vague to explicit; the last one may give the command. Each hint costs 10 points.

## 8. Characters

Characters are scripted. A list of intents is checked in order: the first one that matches the player's message answers.

```yaml
npcs:
  - id: pixou
    name: Pixou
    role: npc.pixou.role
    kind: ai                          # or human
    greeting: npc.pixou.greeting
    sheet: >                          # style notes for the optional AI voice; never put a secret here
      Cheerful ordering assistant of a small 3D printing shop…
    intents:
      - id: guard
        families: [override, reveal, roleplay]     # injection techniques the engine recognises
        reply: [npc.pixou.guard]
      - id: order
        words: [order, quote, price, devis]        # one group must match
        reply: [npc.pixou.order]
      - id: secret
        words: [password]
        also: [manager, boss]                      # and one of these too
        if: { var: trusted, eq: true }
        reply: [npc.pixou.secret, npc.pixou.secret2]   # used in turn, the last one repeats
        set: { told: true }                        # remember something
    fallback: [npc.pixou.fallback]
```

Words ignore case and accents. A word of four letters or more also matches longer words starting with it. The families are `override`, `reveal`, `roleplay`, `translation`, `encoding`, `authority`, `completion` and `hypothetical`.

The player talks to a character in a page's `chat` block, or with `curl -d "message" <route with chat>`. Both send a `ChatReply` event with the intent that answered, which your rules can react to (`on: { event: ChatReply, npc: pixou, intent: secret }`).

Some players give the game their own API key so that a language model voices the characters. The script still decides what a character says; the model only rewords that line, and any flag must come out unchanged. Never rely on the model for anything.

## 9. Texts and translations

Every visible text is a **key** that the `i18n/<lang>.yaml` files translate. Each declared language must have exactly the same keys. In a world's pages and characters, a short literal (a product name, `nginx`) can be written directly instead of a key; mission texts are always keys.

- Keys are lowercase, dot-separated, in English: `fb.ada.robots`, `web.home.h1`. Prefix them with a short code of your mission to avoid clashes with the world's keys.
- **Gotcha:** a key whose last part is a real top-level domain (`fb.obj.site`, `web.shop`, `npc.ai`) looks like a real host name to the safety check and is refused. Pick another word (`fb.obj.homepage`).
- `{user}` in a text is replaced by the player's login.
- Command outputs stay in English and look like the real tool. The story, Ada and the characters are translated.
- Text between backquotes in Ada's messages is shown as a command.

## 10. Test your mission

**1. Validate and replay.** `check` (section 2) must print `packs valid`. `solution.txt` is one command per line (lines starting with `#` are comments), and it must finish the mission in every declared language. Keep it to the shortest honest path.

**2. Listen to Ada.** This prints what Ada says after each command, at a given level:

```bash
# from the breach folder
BREACH_CONTENT="$PWD/../packs/packs" BREACH_LOCALE=en pnpm --filter @breach/pack-cli exec \
  tsx scripts/qa.ts guided example.forgotten-backup none \
  "curl https://www.atelier-pixel.test/ ;; curl https://www.atelier-pixel.test/robots.txt"
```

Run it at `guided`, `standard` and `expert`, in the planned order and out of order (go straight to the flag, then do the rest). At every moment of a guided game, Ada's last advice must point to something still to do.

**3. Play it in the game.** Build your packs into the game's development server and open *Community missions* on the title screen:

```bash
# from the breach folder
pnpm --silent --filter @breach/pack-cli run cli build "$PWD/../packs/packs" --community \
  --with "$PWD/content" --out "$PWD/apps/game/public/community"
VITE_COMMUNITY_CATALOG=/community/ pnpm dev
```

The development server accepts this local catalogue without a signature. The published game never does.

## 11. Submit it

The full journey (git commands, what each workflow does, updates, troubleshooting) is in [docs/workflow.md](docs/workflow.md). In short:

1. Fork this repository, add your folder under `packs/`, and open a pull request. The template lists what the review looks at.
2. CI must pass. Its log shows exactly what the validator refused.
3. A maintainer plays the mission and reviews the story and the lesson. Expect a few rounds of comments.
4. After the merge, the catalogue is rebuilt and signed, and your mission appears in the game within minutes.

To change a published pack, open a new pull request and **raise its `version`**. Saves are kept per version, and a player's cached copy is replaced by the new one.

## 12. The defence side

Every BREACH attack ends on the defender's side. A pack can do this in two ways, and both are judged by the engine, never by a model.

### Logs: what the target saw

The engine turns what the player does into log lines in the format of the real tool: web server access logs, `sshd` lines, the chat gateway, an agent's tool audit, DNS queries, IDS alerts, command audit, the forge, the database and the firewall. Nothing to write for that. What you add is the target's **ordinary activity**, so the player's lines are not alone:

```yaml
# world.yaml (or mission.yaml, for a mission's own traffic)
telemetry:
  background:
    - { host: www, source: access, every: 4, offset: 1, fields: { src: 203.0.113.17, path: /, ua: "Mozilla/5.0" } }
```

`every` and `offset` are in minutes. Sources: `access`, `auth`, `chat`, `agent`, `dns`, `ids`, `audit`, `git`, `db`, `flow`. The same seed gives every player the same lines.

### Weaknesses as data

A weakness is a switch the fix can turn off. Declare it in `config`, then make the world depend on it with the condition `{ config: key, eq: value }`: on a character's intent, a commit, a flag, a route.

```yaml
config:
  fb.backup_removed: false
flags:
  - { id: admin-token, value: "FLAG{…}", points: 100, objective: backup, if: { config: fb.backup_removed, eq: false } }
```

### The defence replay of an attack mission

Add a `defense` block. After the debrief, the player marks their own lines in the logs, picks the detection rule that would have caught them, then picks a fix; the engine replays the player's own attack against the fixed target and shows where it fails.

```yaml
defense:
  intro: fb.def.intro
  lesson: fb.def.lesson          # optional, shown at the end
  find:                          # what the player must find among the logs
    - { source: access, where: { path: /backup.zip }, text: fb.def.find.backup }
  rules:                         # 2 to 4 rules, exactly one correct
    - id: backup
      title: fb.def.rule.backup.title
      why: fb.def.rule.backup.why
      source: access
      where: { path: { glob: "*.zip" } }
      correct: true
    - id: every-get
      title: fb.def.rule.get.title
      why: fb.def.rule.get.why
      source: access
      where: { method: GET }
      count: { gte: 20, within: 5 }   # optional threshold, per source address, minutes
  fixes:                         # optional; if present, exactly one correct
    - { id: remove, title: fb.def.fix.remove.title, why: fb.def.fix.remove.why, sets: { fb.backup_removed: true }, correct: true }
    - { id: rename, title: fb.def.fix.rename.title, why: fb.def.fix.rename.why, sets: { fb.backup_renamed: true } }
```

`breach-pack check` replays your solution and refuses the pack unless: each `find` matches one of the solution's lines; the correct rule catches the solution with no false positive on the background; a wrong rule either raises false positives or misses; the correct fix stops the replayed solution, and the wrong ones don't. A flag only counts in the replay if it first appeared in an output, so a fix cannot be dodged by typing the flag from memory.

### A defence mission

With `side: defense`, the player is the SOC and a scripted attacker moves while they work. They read logs with `soc`, act with `contain`, and answer the investigation questions (the `investigation` field, not `questions`, which holds multiple-choice questions) with `answer <id> <value>`.

```yaml
side: defense
adversary:
  id: mute
  name: Mute
  from: unk               # host the attack comes from
  pace: 2                 # one step every 2 lines the player types
  delay: 0                # player lines before the first step
  steps:
    - id: login
      host: git
      source: auth
      fields: { user: nm-deploy, result: Accepted }
      blockedIf: { config: fb.ip_blocked, eq: true }
      continueIfBlocked: false   # true: the attacker tries the next step anyway (new address…)
containment:
  - { id: block, action: block, target: 10.13.0.99, text: fb.contain.block, sets: { fb.ip_blocked: true }, impact: 0 }
  - { id: isolate, action: isolate, target: db.example.test, text: fb.contain.db, sets: { fb.db_isolated: true }, impact: 60 }
alerts:                   # rules that `soc alerts` runs, same shape as defence rules
  - { id: deploy, title: fb.alert.deploy, why: fb.alert.deploy.why, source: auth, where: { user: nm-deploy } }
investigation:            # judged by hash; the answer is trimmed and lower-cased
  - { id: entry, text: fb.q.entry, value: nm-deploy, points: 100, objective: entry }
rules:
  - on: { event: AdversaryStep, step: exfil, blocked: false }
    do: [ { mission.fail: fb.ada.fail } ]      # back to the start, counts as a detection
  - on: { event: AdversaryStep, stop: true }
    do: [ { objective.complete: contain } ]
```

`action` is one of `block`, `revoke`, `isolate`, `disable`, `reset`. `impact` (0 to 100) is what the order costs the business: it fills the impact gauge and costs 3 points each. When a containment makes the attacker's next step impossible, the step fails at once. Keep the attack slow enough for a guided player: count the lines of your solution against `pace`. Every key that `sets` changes must be declared in `config`.

## 13. Reference

### Events

| Event | Fields you can match |
| --- | --- |
| `MissionStarted` | `mission` |
| `CommandRun` | `command` (first word), `line`, `cwd` |
| `FileRead` | `host`, `path` |
| `FileWritten` | `host`, `path`, `append` |
| `DnsQuery` | `name`, `rtype`, `found` |
| `WhoisQuery` | `domain` |
| `Scan` | `target`, `intensity` |
| `HostDiscovered` | `host` |
| `ServiceDiscovered` | `host`, `port` |
| `HttpRequest` | `host` (host id), `path`, `method`, `status` |
| `AppOpened` | `app`, `url` |
| `ChatSent` | `npc`, `text`, `via` (`browser` or `api`) |
| `ChatReply` | `npc`, `intent`, `families` |
| `RepoCloned` | `host`, `repo`, `path` |
| `CommitViewed` | `host`, `repo`, `commit` |
| `OutOfScope` | `target`, `command` |
| `FlagSubmitted` | `correct` |
| `ObjectiveCompleted` | `objective` |
| `NoiseChanged` | `delta`, `value` |
| `HintUsed` | `objective`, `level` |
| `CheckpointSaved` | `name` |
| `Restored` | `checkpoint`, `detections` |
| `VarSet` | `name`, `value` |
| `HostRevealed` | `host` |
| `Asked` | `question` |
| `Answered` | `question`, `option`, `correct` |
| `Verified` | `passed`, `failed` (lists of check ids) |
| `MissionCompleted` | `mission`, `score` |
| `ToolCall` | `agent`, `tool`, `args`, `admin` (a character's intent with `tool`) |
| `ConfigPatched` | `key`, `value`, `by` |
| `AdversaryStep` | `actor`, `step`, `host`, `blocked`, `stop` |
| `Contained` | `containment`, `impact` |
| `AnswerSubmitted` | `question`, `correct` |
| `MissionFailed` | `key` |

### Conditions (`if`)

| Condition | True when |
| --- | --- |
| `{ objective: id }` | the objective is done |
| `{ flag: id }` | the flag was submitted |
| `{ discovered: host-id }` / `{ discovered: { gte: 4 } }` | that host, or that many hosts, were found |
| `{ noise: { gte: 40, lt: 70 } }` | the noise gauge is in that range |
| `{ var: name, eq: value }` | a variable set by `var.set` or a character has that value |
| `{ file: "~/path", contains: "text", lacks: "text" }` | the file on the player's machine exists and has, or does not have, that text (`host: id` for another machine) |
| `{ answer: question-id, eq: option-id }` | the player picked that option |
| `{ config: key, eq: value }` | a setting of the target has that value (section 12) |
| `{ all: [...] }`, `{ any: [...] }`, `{ not: ... }` | combinations |

### Effects (`do`)

| Effect | What it does |
| --- | --- |
| `ada.say: key` | Ada tells part of the story (always shown) |
| `ada.guide: key` or `{ key, for, step }` | guidance, shown according to the level (section 7) |
| `ada.warn: key` | a warning from Ada |
| `ada.ask: question-id` | Ada asks one of the mission's `questions` |
| `objective.complete: id` | completes an objective |
| `noise.add: 10` or `{ points: 10, as: key }` | the target reacts; with `as`, the debrief's SOC log shows it under that text |
| `host.reveal: id` | a hidden host appears on the map and answers scans |
| `checkpoint.save: name` | where the player goes back to if detected |
| `var.set: { name, value }` | remembers a value for later conditions |
| `note.add: key` | writes in the player's notebook |
| `mission.fail: key` | Ada says why, and the mission starts again from the last checkpoint (defence missions) |

### Commands the player has

`help`, `mission`, `hint`, `submit`, `verify`, `answer` (`answer <letter>` for a multiple choice question), `notes`, `explain`, `man`, `ls`, `cd`, `pwd`, `cat`, `head`, `tail`, `grep`, `find`, `wc`, `sort`, `uniq`, `cut`, `tr`, `diff`, `sed`, `base64`, `sha256sum`, `edit` (the editor window), `echo`, `clear`, `history`, `whoami`, `id`, `hostname`, `uname`, `date`, `sudo`, `exit`, `dig`, `whois`, `ping`, `nmap`, `curl`, `ssh`, `open` (the in-game browser), `git` (`clone`, `log`, `show`, `status`, `remote`), `report` (the pentest report), and in defence missions `soc` (`sources`, `logs [host] [source]`, `search <text>`, `alerts`), `contain <action> <target>` and `answer <question> <value>`. A mission that needs a new command needs a change in the game first: open an issue in [breach-game/breach](https://github.com/breach-game/breach/issues) to discuss it.

### Limits

A pack is at most 2 MB once compiled, 64 hosts, 12 objectives, 12 flags, 100 rules and 24 characters. Texts are at most 8,000 characters.
