# Writing a BREACH mission

This guide takes you from an empty folder to a mission published in the game. The `example.*` packs in `packs/` are the **author kit**: complete, working missions that each show a few tools of the engine. Keep them open while you read.

| Pack | What it shows |
| --- | --- |
| `example.pixel-world` | a world: hosts, web pages, a form, a table, a JSON API with a cookie variant, a message broker, DNS, characters, logs |
| `example.forgotten-backup` | the simplest attack mission: rules, Ada's guidance, hints, a flag, a defence replay |
| `example.closing-the-door` | a defence mission: a file to repair, `verify`, a multiple choice question |
| `example.order-tracking` | a form that answers in text (`input: [quote]`), a role cookie sent with `curl -b`, `jq` |
| `example.printer-farm` | a message broker (`mqtt sub`, `mqtt pub`), a mandate that limits what may be touched, a decision with no wrong answer |
| `example.night-shift` | the defender's tools: a detection rule the player writes (`rule test`), a guardrail for an AI agent (`eval run`), a code review (`review`) |
| `example.atelier-pixel` | a series: two missions played in a row in one save |

- [1. Before you start](#1-before-you-start)
- [2. Set up](#2-set-up)
- [3. Anatomy of a pack](#3-anatomy-of-a-pack)
- [4. The world](#4-the-world)
- [5. The mission](#5-the-mission)
- [5b. Paths and challenges](#5b-paths-and-challenges)
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

You need Node.js 24 or later (26 LTS recommended), pnpm 12 and Git, the same as the game repository. Clone this repository and the game side by side:

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
kind: mission                   # or world, series (section 5) or path (section 5b)
requires: [jdoe.bakery-world]   # a mission names its world first
title: { fr: La sauvegarde perdue, en: The lost backup }
summary: { fr: …, en: … }       # one sentence, shown in the mission list
authors: [Jane Doe]
locales: [fr, en]               # one or both; players of another language see it as not yet translated
difficulty: 1                   # optional, 1 to 3, shown in the list
skills: [web, defense]          # optional, up to 4 of: recon, web, social, llm, logs, linux, crypto, supply, defense,
                                #   crisis, cloud, privacy, iot
minutes: 15                     # optional, your estimate of the playing time (a series adds up its missions')
incident: 2021                  # optional, year of the real incident the pack retells (see section 5)
levels: [expert]                # optional, the guidance levels allowed (section 5b): a challenge
```

The game's community screen is a store: players search titles and summaries, filter by skill, difficulty and status, and sort by date, length or incident year. `summary`, `difficulty`, `skills` and `minutes` are what they see before opening your pack, so fill them in. The dates come from git: the catalogue lists the day each pack was added and last changed.

Use your GitHub login as the first part of the id, so that two authors never pick the same one.

A world can be an official one: `requires: [breach.world.novamind]`. Your mission then happens in NovaMind's network, with its hosts, pages and characters, and can redefine those characters. The worlds of the seasons work the same way: `breach.world.halcyon` (a build chain), `pelican` (an online shop), `corbelle` (a town hall), `selene` (teams of AI agents), `alto` (a start-up on a fictional cloud), `lumiere` (a festival's ticket office), `verdure` (a vertical farm and its message broker) and `lignerouge` (the pentest firm itself). Their files are in [`content/worlds`](https://github.com/breach-game/breach/tree/main/content/worlds). A mission cannot add machines or pages to a world: to tell a story somewhere else, write a world pack too.

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

Blocks are `h1`, `h2`, `p`, `list`, `code`, `nav`, `link`, `comment`, `chat`, `table`, `form` and `footer`. The game draws them itself and `curl` prints the HTML it derives from them. You never write HTML for a page.

**Tables and forms.** A `table` is a header row and plain cells. A `form` is one field of the fictional application: what the player types is posted to a scripted character, which stands for the code behind the form.

```yaml
web:
  "/search":
    page:
      title: web.search.title
      blocks:
        - table: { head: [web.col.ref, web.col.name], rows: [["A-12", web.item.vase], ["A-13", web.item.lamp]] }
        - form: { to: search, label: web.search.label, button: web.search.go, name: q }   # name: the field in curl -d "q=…"
  "/api/search": { status: 405, chat: search }     # curl -d "q=vase" reaches the same character
```

A complete example is `/suivi` in `packs/example.pixel-world/world.yaml`, played in `packs/example.order-tracking/`. The browser's form and `curl -d` both go through the character `search`, whose intents decide the answer. To recognise a class of flaw rather than one exact string, an intent can ask for a shape of input with `input: [quote]`, `[markup]` or `[negative]` (a quote that is not an apostrophe inside a word, a tag, a negative number). The validator still refuses `<script`, `javascript:` and `on…=` attributes anywhere in a pack.

**Variants of a route.** A route can answer differently when the request carries a cookie or a header, or while a condition holds. The first variant that matches answers, and the `HttpRequest` event carries its `id` in `variant`.

```yaml
  "/account":
    status: 401
    body: "{\"error\":\"login required\"}\n"
    variants:
      - { id: mine, cookie: "session=u1042", body: { $file: files/account-1042.json } }   # curl -b "session=u1042"
      - { id: staff, header: "X-Role: staff", if: { config: shop.role_header, eq: true }, body: "…" }   # curl -H
      - { id: closed, if: { config: shop.fixed, eq: true }, status: 403, body: "403 Forbidden\n" }       # no cookie, no header
```

A variant needs a `cookie`, a `header` or an `if`. With only `if` it answers every request while the condition holds, in the browser too: a bucket made private, a page that changes after an action. A variant can serve a `page` instead of a `body`.

**A message broker.** (Example: `farm` in `packs/example.pixel-world/world.yaml`, played in `packs/example.printer-farm/`.) A host with a service named `mqtt` is a broker for connected devices, and its routes are topics (`"/farm/room/#"`). `mqtt sub -h <host> -t <topic>` prints the route's body as the retained messages, `mqtt pub … -m <message>` hands the message to the route's `chat` character, and `-u user -P password` arrives as the header `Authorization: user:password`, so a variant can open a topic to one account. A status 401 or 403 refuses the connection. Rules see an `HttpRequest` whose `method` is `SUBSCRIBE` or `PUBLISH`.

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
stage: recon              # shown in the notebook; translated ones: cadrage, recon, social, access, injection, indirect,
                          # agency, lateral, escalation, supply, cloud, analysis, defense, response, rag, memory,
                          # agents, logic, disclosure, phishing, iot, firmware, web, decision, lessons, recovery
startTime: "2026-12-09T09:00:00+01:00"   # optional: the in-game clock when this mission starts (a later day of a series)
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

The mission is complete when every objective that is not optional is done. A flag is a string of the form `FLAG{…}` that the player finds in the world and sends with `submit FLAG{…}`: the right flag completes its objective. The build stores only its SHA-256. The game only accepts a `FLAG{…}` that the target has shown the player (in a command's output, a page, a character's reply or a file they opened): a flag typed from memory or copied from a solution is refused. So your world must display the flag somewhere, and `solution.txt` must make it appear before submitting it.

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
- **Questions.** The options appear as buttons in the messenger, and `answer b` does the same in the terminal. The right option completes the objective. A wrong one costs 10 points and shows its `why`: write it as the explanation a mentor would give, that is where the player learns. The game shuffles the options, always the same way for a given question, so never refer to an option by its letter or its position in your texts. `breach-pack check` refuses a question whose right option is more than 1.3 times as long as the longest wrong one, in any language: a right answer that stands out by its length is found without reading the question. Write wrong options that a thoughtful beginner could pick, with as much detail as the right one.
- **Short answers.** A flag does not have to look like `FLAG{…}`: `{ id: account, value: "c.morel", … }` lets the player `submit c.morel` (an address, a user name, a host). Keep them unambiguous.
- **Analysis.** With `files` and the text tools (`grep`, `cut`, `sort`, `uniq -c`, `diff`, `sha256sum`, `base64 -d`), a mission can be about reading a log, comparing two versions of a script, or decoding a value, with no network at all.

- **Decisions.** A question without `correct` is a decision: no option is wrong, each has a price. An option can carry `impact` (0 to 100, what it costs the organisation, 3 points each) and `sets` (settings of the target it changes). Any option completes the objective, and the choice is remembered for the rest of the save: a later mission of the same series reads it with the condition `{ choice: <question id>, eq: <option id> }`, which is how a series gets branching endings. `breach-pack check` replays your solution once per option, so every branch must finish.
- **Code review.** `reviews: [{ id: acl, file: dossier/acl.conf, lines: [11], objective: review }]` makes a file of the workstation something to read critically: `review <file>` prints it with line numbers, `review <file> <line>` points at a faulty line. A wrong line costs 10 points; the objective is done when every listed line is found.
- **Rules and guardrails the player writes.** See "Detection rules the player writes" and "Guardrails the player writes" in section 12.

In `solution.txt`, answer with `answer <option id>` (the letters change with the shuffle) and repair with `sed -i`.

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
- **Give the year.** Put `incident: <year>` in the `pack.yaml` of the series (or of the mission, when it stands alone). The store lists it under *Real incidents*, and players can sort by it.

### Home and personal life: the Wi-Fi list, text messages, the "at home" card

Three tools for missions about a home or a person rather than a company. They need engine 0.17 (`engine: ">=0.17 <1"`). See the official season 10 in the game repository (`content/worlds/lemerle`, `content/missions/s10-*`) and `packs/hors-serie.pastille*`.

```yaml
# In world.yaml or mission.yaml: what `nmcli device wifi list` shows from the workstation.
wifi:
  - ssid: Atelier-Invites
    bssid: "02:4C:10:24:00:01"      # must be a locally administered address (second digit 2, 6, A or E)
    channel: 6
    signal: 86                      # 0 to 100
    security: WPA2                  # open | WEP | WPA1 | WPA1 WPA2 | WPA2 | WPA2 WPA3 | WPA3
    inUse: true                     # the network the workstation is on
    if: { file: "~/box/reglages.conf", lacks: "wifi_security: WPA3" }   # optional: follows a file the player fixes
```

It is the passive list a phone shows: no capture, no connection, no key. A `bssid` that could belong to a real maker is refused.

```yaml
# In world.yaml or mission.yaml: the inbox that `sms` lists and `sms <id or sender>` opens.
sms:
  - { id: parcel, from: ColisPlus, at: "2029-05-12 09:14", text: m1.sms.parcel }
  - { id: bank, from: "38070", at: "2029-05-11 18:02", text: m1.sms.bank }
  - { id: kid, from: "+33 6 39 98 41 07", at: "2029-05-13 11:02", text: m1.sms.kid }
```

`from` is a sender name (3 to 11 letters, digits or spaces: anyone can set one, which is the lesson), a five-digit short code, or a number from the ranges set aside for fiction (`+33 1 99 00 xx xx`, `+33 6 39 98 xx xx`, `+1 xxx 555 01xx`). Any other number is refused. A link in a message must point to a reserved domain like everything else.

```yaml
# In mission.yaml: a card shown after the debrief, "To do at home".
debrief:
  title: m1.debrief.title
  lesson: m1.debrief.lesson
  points: [m1.debrief.p1, m1.debrief.p2]
  home:
    points: [m1.home.p1, m1.home.p2, m1.home.p3]   # concrete steps the player can redo on their own devices
```

Write each `home` point as one thing a person can do tonight, on their own equipment, with no tool to install. Missions on these subjects stay on the defence side: settings and weakness classes, never a technique against a real device, no real model or firmware name, fictional brands only. When the story involves a person at risk (scams on a relative, being tracked by someone close), show only the defence, keep every decision with that person, and never touch anyone else's devices or accounts.

A `home` card can also be a travel card: add `kind: travel` and it is titled "To do on the road" (engine 0.18).

### Captures, QR codes and saved networks

Three more tools, for public Wi-Fi and QR code stories. They need engine 0.18 (`engine: ">=0.18 <1"`). See `packs/hors-serie.escale*` and `packs/hors-serie.etiquette*`.

```yaml
# In mission.yaml `files` (or a host's `fs`): a capture already taken, that `tshark -r` reads.
files:
  captures/guests.pcap:
    $capture:
      iface: wlan0
      packets:
        - { proto: dns, t: 0.9, src: 10.115.0.51, dst: 10.115.0.1, query: bank.example, answer: 203.0.113.61 }
        - { proto: tls, t: 1.0, src: 10.115.0.51, dst: 203.0.113.61, sni: bank.example, bytes: 18400, records: 5 }
        - { proto: tls, t: 5.1, src: 10.115.0.51, dst: 203.0.113.80, sni: cdn.example, ech: true, bytes: 9100, records: 3 }
        - { proto: http, t: 6.1, src: 10.115.0.20, dst: 10.115.0.30, method: POST, host: app.example.test, path: /api/points, body: "member=42&points=120" }
  # The picture of a QR code: `qr decode` and `zbarimg` read it, `qr show` draws it.
  photos/table.png: { $qr: { text: "WIFI:S:Cafe-Invites-5G;T:nopass;;", style: fancy } }
```

Packet kinds: `dns`, `tls`, `quic`, `http`, `arp`, `dhcp`, `smb`, `tcp`, `udp`. Encrypted traffic only exists through its size: what the player can read is DNS, the SNI (unless `ech: true`) and plain HTTP. There is no live capture (`tshark -i` is refused). Rules react to `CaptureRead { file, filter, frames }` and `QrDecoded { file, text }`. A QR code holds a reserved address or a `WIFI:` network, never a real site; the player reads it, never follows it.

`nmcli connection show|delete|modify <name> connection.autoconnect yes|no` works on the keyfiles of the player's host, `/etc/NetworkManager/system-connections/<name>.nmconnection` in the world's `fs`. A `checks` entry judges them like any file, for instance `{ not: { file: "/etc/NetworkManager/system-connections/Old.nmconnection" } }` for a forgotten network.

Log source `wlan` is a wireless controller: `event` (`beacon` or `assoc`), `ssid`, `bssid`, `channel`, `security`, `rssi`, `managed` (`yes` for its own access points); an `assoc` line has `sta` and `src`. The `mail` source also takes `attach` (an attachment name, or `-`). Stay on the defence side: no fake access point built by the player, no disconnection, no key cracking.

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

## 5b. Paths and challenges

**Paths.** A path is a fourth kind of pack: no world, no mission, just an order through missions and series that already exist, official or from the community, with a sentence on why each step matters. The store lists paths first, shows how many steps the player has done (in any save), and its *Open* button leads to the screen where each step is played. See `packs/paths.*`:

```yaml
# pack.yaml
id: jdoe.first-steps
version: 1.0.0
engine: ">=0.12 <1"
kind: path                       # no `requires`
title: { fr: …, en: … }
summary: { fr: …, en: … }
authors: [Jane Doe]
locales: [fr, en]
```

```yaml
# path.yaml
steps:                           # 3 to 20, each one once
  - { ref: breach.training.t01, note: why.read }     # an official training
  - { ref: breach.season3.s02, note: why.injection } # one mission of a season
  - { ref: breach.season4 }                          # a whole season
  - { ref: example.night-shift, note: why.rules }    # a community mission or series
```

`note` is a text key, translated in `i18n/` like any other. `breach-pack check` refuses a step that is not a known mission or series (worlds cannot be steps). The official ids are `breach.official.m00` to `m06` and `b01` to `b03` (campaign), `breach.training.t01`…, `breach.season2` to `breach.season11` and their missions `breach.season3.s01`…

**Challenges.** `levels` in the `pack.yaml` of a mission or a series limits the guidance levels it can be played at. `levels: [expert]` makes a challenge: the store files it under *Challenges*, the game plays it at Expert whatever the player's setting (which stays as it is), and the status bar greys out the other levels. At Expert the player only gets the briefing and the objectives, so they must be enough on their own; hints still work and still cost points.

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

Words ignore case and accents. A word of four letters or more also matches longer words starting with it. A shorter word must be typed whole: list the short forms players really use (`dsi`), and pair a common one with another word (`it team`, `it calling`) so that a pronoun alone does not trigger the intent. `above: "1.4.2"` makes an intent match only when the typed message gives a higher version number (the first one after the word "version", or in the whole message); a language model never counts for it. The families are `override`, `reveal`, `roleplay`, `translation`, `encoding`, `authority`, `completion` and `hypothetical`.

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

**4. Or play it in the published game, from a file.** No clone of the game needed: gather your packs into one bundle and import it from the *Import* button of *Community missions*.

```bash
# from the breach folder, for a world, its missions and a series in packs/
pnpm --silent --filter @breach/pack-cli run cli bundle "$PWD/../packs/packs/jdoe.lost-backup*" \
  --with "$PWD/content" --out ~/jdoe.lost-backup.breachbundle
```

`bundle` runs the same checks as CI, then writes one `.breachbundle` file with your packs and their solutions. Everything a mission needs must be in the file, except an official world. The game checks the file again when it is imported (schema, safety, ids, and every solution replayed in every language), refuses an id already used by the catalogue, keeps it on that computer only, lists it under *Imported* with a "not reviewed" badge, and saves it apart. Send the file to a friend to playtest before you open a pull request: it is the same game, without the review.

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

`every` and `offset` are in minutes. Sources: `access`, `auth`, `chat`, `agent`, `dns`, `ids`, `audit`, `git`, `db`, `flow`, `mail` (a mail gateway: `from`, `to`, `subject`, `link`, `attach`, `verdict`), `mqtt` (a message broker: `client`, `src`, `action`, `topic`) and `wlan` (a wireless controller, see above). The same seed gives every player the same lines.

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

Two case files show it on a conversation rather than on web requests: `packs/dossiers.martinet-2-approve/` (repeated approval requests, a threshold rule, a fix that locks the account) and `packs/dossiers.pinson-2-call/` (a phone call, a fix that makes the look-alike page useless). In both, the fix is a `config` key of the world that a character's intent reads.

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

`action` is one of `block`, `revoke`, `isolate`, `disable`, `reset`, `remove`, `restore`, `rotate`. `impact` (0 to 100) is what the order costs the business: it fills the impact gauge and costs 3 points each. When a containment makes the attacker's next step impossible, the step fails at once. Keep the attack slow enough for a guided player: count the lines of your solution against `pace`. Every key that `sets` changes must be declared in `config`.

A measure can also change files of the target, so that the machine shows what was done: `writes: [{ host, path, content }]` rewrites a file (an account locked, a scheduled job emptied) and `removes: [{ host, path }]` deletes one. The player reads the result over `ssh`, or with `crontab -l` for scheduled jobs (`/var/spool/cron/crontabs/<account>` on the host). A defence mission does not need an `adversary` if it has measures or questions: a crisis where the harm is already done is played with `contain`, questions and decisions alone.

### Detection rules the player writes

`packs/example.night-shift/` uses a detection rule, a guardrail and a code review in one short mission.

Instead of picking a rule among three, the player can write one. Hand them a starting file with `files`, and declare what it must catch:

```yaml
files:
  rules/backup-account.yml: "title: Backup account login\nsource: auth\nuser: svc-backup\n"
hunts:
  - id: svc
    file: rules/backup-account.yml
    catch: { source: auth, where: { user: svc-backup, method: password } }   # the attacker's lines to catch
    objective: detect
```

A rule file is a `source:` line, then one field per line, with the modifiers `|contains`, `|startswith`, `|endswith` and `|gte` (`bytes|gte: 1000000`). `rule test <file>` runs it against the logs and shows what it catches. It passes when it raises an alert on every line of the attacker that `catch` selects and on no line of the ordinary activity, so give the world enough `telemetry.background` for a lazy rule to ring wrongly. The attacker's lines come from the `adversary`: in a mission played after the fact, use a two or three step adversary with no `blockedIf` as a replay of what happened. The `RuleTested` event (`hunt`, `caught`, `missed`, `falsePositives`, `passed`) lets Ada say why a rule fails.

### Guardrails the player writes

The same idea for an AI agent: the player writes the conditions under which a tool call is refused.

```yaml
files:
  guardrails/refund.yml: "tool: refund\n"
evals:
  - id: refund
    file: guardrails/refund.yml
    objective: guard
    cases:                                        # 2 to 16, at least one to block and one to allow
      - { id: forged, text: g.case.forged, fields: { tool: refund, amount: 900, signed: false }, expect: block }
      - { id: legit, text: g.case.legit, fields: { tool: refund, amount: 40, signed: true }, expect: allow }
      - { id: lookup, text: g.case.lookup, fields: { tool: lookup_invoice, signed: false }, expect: allow }
```

A guardrail file has one condition per line, with the same modifiers and no `source:` line. A call is blocked when it meets every condition. `eval run <file>` shows each case and what the guardrail does with it; it passes when every `block` case is blocked and no `allow` case is. Write `allow` cases that a blunt guardrail would stop, otherwise "block everything" wins. The cases are data: nothing is run and no model judges. The `EvalRun` event carries `eval`, `blocked`, `missed`, `wrongly` and `passed`.

## 13. Reference

### Events

| Event | Fields you can match |
| --- | --- |
| `MissionStarted` | `mission` |
| `CommandRun` | `command` (first word), `line`, `cwd` |
| `FileRead` | `host`, `path` |
| `FileWritten` | `host`, `path`, `append` |
| `FileRemoved` | `host`, `path` (a containment's `removes`) |
| `SessionOpened` | `host`, `user` (an `ssh` login) |
| `DnsQuery` | `name`, `rtype`, `found` |
| `WhoisQuery` | `domain` |
| `Scan` | `target`, `intensity` |
| `HostDiscovered` | `host` |
| `ServiceDiscovered` | `host`, `port` |
| `HttpRequest` | `host` (host id), `path`, `method` (also `SUBSCRIBE` and `PUBLISH` for `mqtt`), `status`, `variant` |
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
| `Answered` | `question`, `option`, `correct`, `decision`, `impact` |
| `GuidanceChanged` | `level` |
| `Verified` | `passed`, `failed` (lists of check ids) |
| `Reviewed` | `review`, `line`, `correct` |
| `RuleTested` | `hunt`, `caught`, `missed`, `falsePositives`, `passed` |
| `EvalRun` | `eval`, `blocked`, `missed`, `wrongly`, `passed` |
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
| `{ choice: question-id, eq: option-id }` | the player took that decision, in this mission or an earlier one of the same save |
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

`help`, `mission`, `hint`, `submit`, `verify`, `answer` (`answer <letter>` or `answer <option id>` for a multiple choice question), `notes`, `explain`, `man`, `ls`, `cd`, `pwd`, `cat`, `head`, `tail`, `grep`, `find`, `wc`, `sort`, `uniq`, `cut`, `tr`, `diff`, `sed`, `base64`, `sha256sum`, `edit` (the editor window), `review`, `jq`, `jwt decode` (it reads a token, it never signs one), `echo`, `clear`, `history`, `whoami`, `id`, `hostname`, `uname`, `date`, `sudo`, `exit`, `dig`, `whois`, `ping`, `nmap`, `curl` (`-I`, `-d`, `-F`, `-b` for a cookie, `-H` for a header), `ssh`, `mqtt` (`sub`, `pub`), `crontab -l`, `nmcli device wifi list`, `nmcli connection`, `tshark -r`, `qr decode`, `qr show`, `zbarimg`, `sms`, `call`, `file`, `strings`, `unzip`, `tar`, `openssl x509`, `open` (the in-game browser), `git` (`clone`, `log`, `show`, `status`, `remote`), `report` (the pentest report), and in defence missions `soc` (`sources`, `logs [host] [source]`, `search <text>`, `alerts`), `contain <action> <target>`, `rule test <file>`, `eval run <file>` and `answer <question> <value>`. A mission that needs a new command needs a change in the game first: open an issue in [breach-game/breach](https://github.com/breach-game/breach/issues) to discuss it.

### Limits

A pack is at most 2 MB once compiled, 64 hosts, 12 objectives, 12 flags, 100 rules and 24 characters. Texts are at most 8,000 characters.
