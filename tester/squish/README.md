# Squish GUI tests

Automated GUI tests for the Linphone desktop app, driven by [Squish for Qt] and run in CI
against the Linux AppImage. Tests live in `suites/cross-platform/` and are written in JavaScript.

Two kinds of test case:
- **script cases** (`tst_*`) — a `test.js` with a `main()`.
- **BDD cases** (`tst_BDD_*`) — a Gherkin `test.feature`, a `test.js` driver and step
  implementations under `steps/`. The `.feature` comes from
  [linphone-test-specs](https://gitlab.linphone.org/BC/private/linphone-test-specs), included as the
  `external/feature-specs` submodule and shared with the other platforms.

## Overview

```
external/feature-specs/         SUBMODULE: the shared Gherkin specs (linphone-test-specs)
tester/squish/
  run-ci.sh                     CI entry point (orchestrates one run)
  tools/
    account_manager.py          provisions/deletes a SIP test account on the server
    gen_translations.py         builds the key->text map for a language
    seed_config.py              writes a linphonerc for a test instance (logged-in profile)
    seed_setting.py             writes a linphonerc with [ui] settings for a test instance
    sync_features.py            copies the specs from external/feature-specs into the BDD test cases
  suites/cross-platform/
    suite.conf                  AUT name + list of test cases
    tst_Startup/test.js         a script test case
    tst_Login/test.js           a script test case
    tst_BDD_Redial/
      test.js                   BDD driver (runs test.feature)
      steps/redialSteps.js      step implementations
      test.feature              GENERATED per run from external/feature-specs (gitignored)
    shared/scripts/
      squishlib.js              low-level finder (tree walker)
      translate.js              tr(key) -> translated text
      serverAccount.js          provisionedAccount() -> the account credentials
      bdd_hooks.js              BDD scenario hooks (suite-wide)
      app.js, welcomePage.js, loginPage.js, sipLoginPage.js, mainPage.js,
      chatPage.js, callPage.js, settingsPage.js, dialerPage.js, callWindow.js,
      contactsPage.js, historyPage.js              page objects (one per screen)
      redialFixture.js          per-scenario app lifecycle for tst_BDD_Redial
      currentTranslations.js    GENERATED per run (gitignored)
```

The CI job is `ubuntu2204-squish-tests` in `.gitlab-ci-files/linux-squish.yml`.

---

## Running locally (outside CI)

You don't need the CI container — any machine with Squish for Qt installed and licensed can run
the suite against a **local build**.

**Prerequisites**
- Squish for Qt installed (`squishserver` / `squishrunner`) and licensed (`~/.squish-license`).
- A local build of the app (a build tree, an extracted AppImage, or `Linphone.app` on macOS).
- `python3` (for the helper tools).
- Network so accounts can be provisioned: `*.example.org` must resolve to the test
  infrastructure (CI does this via DNS `217.182.172.169` = `fs-test-10.linphone.org`). Off-CI you
  need the same resolution (VPN / DNS / `hosts`), or point `FLEXIAPI_URL` / `SIP_DOMAIN` at a
  reachable server.

**Steps** (from the repo root)
```bash
B="/opt/squish-for-qt-9.0.1/bin"        # macOS: "/Applications/Squish for Qt 9.0.1/bin"
SUITE=tester/squish/suites/cross-platform

# 1. Generate the key->text map for the language you want to test
python3 tester/squish/tools/gen_translations.py en > "$SUITE/shared/scripts/currentTranslations.js"

# 1b. Bring in the shared Gherkin specs (once) and copy them into the BDD test cases
git submodule update --init external/feature-specs
python3 tester/squish/tools/sync_features.py

# 2. Provision a throwaway SIP account (exports SQUISH_SIP_*)
eval "$(python3 tester/squish/tools/account_manager.py create --export)"

# 3. Register your local build as the AUT named "Linphone" (dir containing the `linphone`
#    executable: <build>/bin, the AppImage's squashfs-root/usr/bin, or Linphone.app/Contents/MacOS)
"$B/squishserver" --config addAUT Linphone /path/to/build/bin
"$B/squishserver" --daemon

# 4. Run (English needs no app hook; other languages need a build carrying LINPHONE_FORCE_LANGUAGE)
export LINPHONE_FORCE_LANGUAGE=en
"$B/squishrunner" --testsuite "$SUITE" --reportgen stdout

# 5. Clean up
"$B/squishserver" --stop
python3 tester/squish/tools/account_manager.py delete "$SQUISH_ACCOUNT_ID"
```

**Interactive (squishide)** — open `suites/cross-platform` in squishide and register your build as
AUT `Linphone`. Before running a case, make sure `currentTranslations.js` exists (step 1) and set
`LINPHONE_FORCE_LANGUAGE` and the `SQUISH_SIP_*` vars (from step 2) in the run configuration. Then
run / record / debug test cases interactively.

**Notes**
- On a real desktop you do **not** need Xvfb or `dbus-run-session` — your session already has a
  display and a D-Bus bus. `run-ci.sh` only adds those because the CI container lacks them.
- `run-ci.sh` is container-oriented (AppImage extraction, Xvfb on `:99`, the language loop). You
  *can* run it locally if you replicate that environment and override `SQUISH_BIN_PATH` / `DISPLAY`,
  but the manual steps above are simpler for interactive work.

---

## 1. For developers — writing new tests

Tests are composed from **page objects** (one module per screen) that expose intent-level
actions. A test reads like the manual steps; locators live in the page objects, not the test.

### Add a test case
1. Create `suites/cross-platform/tst_MyThing/test.js`.
2. Add `tst_MyThing` to the `TEST_CASES` line in `suites/cross-platform/suite.conf`.
3. Write the scenario using existing page objects, e.g.:

```js
import { App } from "app.js";
import { WelcomePage } from "welcomePage.js";
import { LoginPage } from "loginPage.js";
import { SipLoginPage } from "sipLoginPage.js";
import { MainPage } from "mainPage.js";
import { provisionedAccount } from "serverAccount.js";

function main(){
    var account = provisionedAccount();
    App.launch();
    WelcomePage.skipIfPresent();
    LoginPage.openThirdPartySipAccount();
    SipLoginPage.acknowledgeWarning();
    SipLoginPage.login(account);
    test.verify(MainPage.waitLoaded(), "Logged in");
}
```

### Add a BDD (Gherkin) test case
Scenarios live in the spec repo, step implementations here.

1. Add or extend the `.feature` in the `external/feature-specs` submodule (a behaviour change needs the PO's
   ack), and merge it there first.
2. Create `suites/cross-platform/tst_BDD_MyThing/` with a `.gitignore` containing `test.feature`, a
   `test.js` driver (copy `tst_BDD_Redial/test.js`) and the steps under `steps/`. `test.feature` is
   generated at run time and never committed.
3. Map the case to its spec in `BDD_TEST_CASES` in `tools/sync_features.py`.
4. Add `tst_BDD_MyThing` to `TEST_CASES` in `suites/cross-platform/suite.conf`.

`run-ci.sh` runs `sync_features.py` before the suite; locally run it by hand (step 1b above), or
squishide reports a missing feature file.

Steps call page objects. Squish placeholders are `|any|`, `|word|`, `|integer|` (not Cucumber's
`{string}`); `Step()` matches under any keyword:

```js
Given("the user has previously dialed the number \"|any|\" manually from the dialer", function(context, number){
    DialerPage.dialOnKeypad(number);
    DialerPage.pressCallButton();
});

Step("the dialer input is empty", function(context){
    test.compare(DialerPage.inputText(), "", "Dialer input is empty");
});
```

Scenario hooks go in `shared/scripts/bdd_hooks.js`, dispatched on `squishinfo.testCase`. Those of
`tst_BDD_Redial` call `redialFixture.js`: one pre-seeded profile per scenario (`redial1..6`, seeded
in `run-ci.sh`), instance killed at scenario end.

### Add / extend a page object
A page object is a module exporting one object with methods. Use the helpers from
`squishlib.js` and resolve user-visible labels with `tr(key)`:

```js
import * as L from "squishlib.js";
import { tr } from "translate.js";

export var SettingsPage = {
    openLogout: function(){ L.click(tr("settings_logout_title"), 15000); }
};
```

The helpers read as plain actions — you never write a raw "find an object where className matches…"
predicate yourself. The common verbs are `click`, `clickIfVisible`, `isVisible`, `isHidden`, `fill`,
`selectInDropdown` (full list below).

### How to find a control
The matcher can't reliably select these custom QML controls by objectName/type, so we
**walk the object tree and match on the displayed text**. Tests reference the **translation
key** (not the English string); `tr(key)` turns it into the text for the language under test.

- Find the key in the QML: a button labelled `qsTr("assistant_account_login")` has key
  `assistant_account_login`. Click it with `L.click(tr("assistant_account_login"))`.
- Check something is shown/hidden with `L.isVisible(tr(key))` / `L.isHidden(tr(key))`.
- Text fields have no usable label — match them by order with `L.textFields()` and fill by index.
- Icon-only controls (dialer call key, per-row call-back button, "new contact" `+`…) show no text:
  they carry an `objectName` in the QML, matched with `L.clickNamed` / `L.waitForNamed`. Add an
  `objectName` when you need one, and don't rename existing ones. `SearchBar` derives its children's
  names from its own: `searchBarObjectName: "newCallSearchBar"` → `newCallSearchBarInput`,
  `newCallSearchBarDialerButton`.
- The in-call window is a separate top-level window, objectName `callsWindow`; use
  `L.waitForWindowNamed` / `L.waitWindowNamedGone`. Its QObject properties are readable directly
  (`window.call.core.remoteAddress`), as done in `callWindow.js`.
- New screens: dump the live tree with a throwaway test that walks `findAllObjects` +
  `object.children()` and logs `className`/`text` (see git history for examples).

### squishlib.js helpers — the vocabulary you write tests with
Everyday actions (take the visible **text**, e.g. `tr(key)`):
- `click(text, timeout)` — click the button/labelled control showing `text` (fails loudly if absent).
- `clickIfVisible(text, timeout)` — click it only if present; returns true/false, never fails.
- `isVisible(text, timeout)` — true if something showing exactly `text` appears in time.
- `isHidden(text, timeout)` — true if it does **not** appear (use for "feature is hidden" checks).
- `waitForText(text, timeout)` — return the element showing `text`, or null.
- `fill(field, value)` — clear a text field and type into it.
- `selectInDropdown(value, timeout)` — open a combo box and pick the item showing `value`.

By `objectName` (for controls with no visible text):
- `clickNamed(name, timeout)` / `waitForNamed(name, timeout)` — click / get the visible control.
- `allNamed(name)` — every visible control with that name (e.g. all call-history rows).
- `namedIn(root, name)` — the same, restricted to one subtree.
- `textIn(root, text)` / `containsText(root, fragment)` — find text inside one subtree only.
- `waitForWindowNamed(name, timeout)` / `waitWindowNamedGone(name, timeout)` — top-level windows.

Lower level (only when the above don't fit):
- `waitFor(matches, timeout)` / `waitGone(matches, timeout)` / `findAll(matches)` — `matches` is a
  function `function(element){ return ... }` returning true for the element you want.
- `hasControlType(regex, timeout)` — true if a visible object's className matches a pattern.

`clickLabel` / `comboPick` / `hasType` are kept as aliases of `click` / `selectInDropdown` /
`hasControlType` so older tests keep working.

### Rules of thumb
- Reference **keys**, never hard-coded English. This keeps tests language- and reword-proof.
- Put locators/flows in page objects; keep test cases short and readable.
- A control that overflows off-screen makes `mouseClick` fail loudly ("outside rendered
  area") — that's a real layout issue for that language, not a test bug.

---

## 2. For DevOps / CI

The job builds nothing itself: it consumes the Linux AppImage from
`ubuntu2204-makefile-gcc-package` and runs `bash tester/squish/run-ci.sh`.

### `external/feature-specs` submodule
`.gitmodules` uses the SSH URL, which CI containers cannot fetch (no ssh client, no key). It is
therefore excluded from the pipeline-wide recursive checkout in `.gitlab-ci.yml`:

```yaml
GIT_SUBMODULE_PATHS: ':(exclude)external/feature-specs'
```

and fetched only by the squish job, over HTTPS with `CI_JOB_TOKEN` (in `before_script`, since GitLab
clones the sources before it runs):

```yaml
before_script:
  - git config --global url."https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.linphone.org/".insteadOf "git@gitlab.linphone.org:"
  - git submodule update --init --depth 1 external/feature-specs
```

`linphone-test-specs` being private, its **Settings → CI/CD → Job token permissions** must authorize
`linphone-desktop`. Otherwise the fetch fails with `repository not found` (GitLab returns 404 for
unauthorized).

### Job variables (defaults in `linux-squish.yml`, overridable)
| Variable | Purpose | Default |
|---|---|---|
| `SQUISH_LINUX_IMAGE` | Squish docker image (the job `image:`) | `…/bc-dev-ubuntu-25-04-squish:<tag>` |
| `SQUISH_BIN_PATH` | Squish binaries inside the image | `/opt/squish-for-qt-9.0.1/bin` |
| `DISPLAY` | X display (host Xvfb) | `:99` |
| `APPLICATION_NAME` / `EXECUTABLE_NAME` | AUT names | `Linphone` / `linphone` |
| `FLEXIAPI_URL` / `SIP_DOMAIN` | account provisioning target | `http://subscribe.example.org/flexiapi/api/` / `sip.example.org` |
| `SQUISH_LANGS` | languages to run, space-separated | `en fr` |
| `SQUISH_TEST_CASES` | `*` for the whole suite, or a CSV of test cases (e.g. `tst_BDD_Redial,tst_Login`) | `*` |

### Required CI/CD variables (set in GitLab → Settings → CI/CD → Variables — NOT committed)
- **`SQUISH_LICENSE_URL`** — the Squish floating license server as `host:port` (port optional,
  defaults to the standard Squish port). **Required**: the job is unlicensed (and fails) without it.
  Intentionally kept out of the repo.
- **`DOCKER_AUTH_CONFIG`** — registry auth (read-only deploy token) so the runner can pull the
  private Squish image. Optional while the image is already cached locally.

When running locally, pass the same way: `SQUISH_LICENSE_URL=host:port bash tester/squish/run-ci.sh`,
or just rely on your own `~/.squish-license` (squishide users already have one).

### Pipeline triggers
- `RUN_SQUISH_TESTS` — gate that enables the job (or trigger the manual job on an MR).
- `PACKAGE_LINUX=true` — needed so the package job produces the AppImage the squish job consumes.

### Setting up a runner VM (from scratch)

The runner host only runs Docker + gitlab-runner; the Squish image is the job's `image:`, so jobs
run inside it and nothing is compiled on the host.

**Machine**
- **x86_64 / amd64** — must match the Linux AppImage (Docker runs the host arch; do **not** use ARM).
- Linux; **Ubuntu 24.04 LTS** is a good choice (the host needn't match the container's 25.04).
- A few GB of RAM/disk; no GPU.

**1. Docker** — install Docker Engine. No `privileged` / docker-in-docker is needed (image-as-job).

**2. Xvfb on the host** — the shared display the container draws to:
```bash
apt-get install -y xvfb
cat >/etc/systemd/system/xvfb.service <<'UNIT'
[Unit]
Description=Xvfb virtual framebuffer on :99
After=network.target
[Service]
ExecStart=/usr/bin/Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp
Restart=always
[Install]
WantedBy=multi-user.target
UNIT
systemctl enable --now xvfb.service
```

**3. Network** — the host/containers must reach:
- the test DNS **`217.182.172.169`** (`fs-test-10.linphone.org`) — resolves `*.example.org` for
  provisioning + SIP registration and forwards the rest (set it as `dns` below);
- the **GitLab registry** `gitlab.linphone.org:4567` (to pull the Squish image);
- the **Squish license server** (the `host:port` from `SQUISH_LICENSE_URL`), reached at run time.

**4. Squish image** — pre-pull it (`docker login gitlab.linphone.org:4567 && docker pull <image>`)
so `pull_policy=if-not-present` uses the cache, or set `DOCKER_AUTH_CONFIG` so the runner pulls it.

**5. gitlab-runner (16.x)** — install it, create a runner in GitLab (Settings → CI/CD → Runners)
tagged **`docker-squish-flat`** with "run untagged jobs" **off**, then put the `glrt-…` token in
`/etc/gitlab-runner/config.toml` and `gitlab-runner install && gitlab-runner start`:
```toml
concurrent = 1                                  # single shared Xvfb -> one squish job at a time
[[runners]]
  name = "linphone-squish-linux"
  url = "https://gitlab.linphone.org"
  token = "glrt-REPLACE_WITH_TOKEN"
  executor = "docker"
  [runners.docker]
    image = "<squish image:tag>"                # overridden by $SQUISH_LINUX_IMAGE at job time
    pull_policy = ["if-not-present"]
    dns = ["217.182.172.169"]                   # test DNS (resolves *.example.org + SRV, forwards rest)
    volumes = ["/cache", "/tmp/.X11-unix:/tmp/.X11-unix"]   # share the host Xvfb socket
    privileged = false
```
Keep `concurrent = 1`: the single shared Xvfb cannot host two squish jobs at once.

### Reports
HTML reports are produced per language under `squish-reports/<lang>/` and uploaded as job
artifacts (`when: always`). They go to a fresh dir (not the downloaded `build/OUTPUT` artifact,
which GitLab extracts as root and the job user cannot write into).

### Adding / restricting languages
Set `SQUISH_LANGS` (e.g. `SQUISH_LANGS="en"` per-MR, all languages nightly). Every language is a
full suite run, so cost scales linearly.

---

## 3. For maintainers — the underlying tools

### `run-ci.sh` (orchestrator)
One run does, in order:
1. Re-exec under `dbus-run-session` (the AUT needs a D-Bus session bus or it exits immediately).
2. Write the floating-license file to `$HOME/.squish-license`.
3. Copy the AppImage to a temp dir and `--appimage-extract` it (no FUSE in containers).
4. Symlink `usr/bin/Linphone -> linphone` (Squish registers the AUT as `Linphone`).
5. Export the AUT runtime env: `QT_QPA_PLATFORM=xcb`, `QT_PLUGIN_PATH`, `QML_IMPORT_PATH`,
   `QML2_IMPORT_PATH` (Squish launches the raw binary, so these must be set explicitly).
6. Provision one SIP account (`account_manager.py create --export` → `SQUISH_SIP_*` env vars).
7. Copy the shared Gherkin specs into the BDD test cases (`sync_features.py`).
8. For each language in `SQUISH_LANGS`: regenerate `currentTranslations.js`, set
   `LINPHONE_FORCE_LANGUAGE`, use fresh `XDG_*` dirs, seed the per-instance profiles
   (`a`/`b`/`c`/`d`, the `set-*` ones and `redial1..6`), `squishserver` + `squishrunner` the suite,
   report under `reports/<lang>`.
9. Delete the provisioned account; exit with the aggregated result.

### `tools/account_manager.py`
Provisions/deletes test SIP accounts via the FlexiAPI **test-admin** flow (same mechanism as the
liblinphone testers): `POST account_creation_tokens` → `POST accounts/with-account-creation-token`
→ `DELETE accounts/<id>`, using the test headers `From: sip:admin_test@sip.example.org` /
`x-api-key: no_secret_at_all`. Config via env/flags: `FLEXIAPI_URL`, `SIP_DOMAIN`, `FLEXIAPI_FROM`,
`FLEXIAPI_API_KEY`. `create --export` prints `export SQUISH_SIP_USER/PASS/DOMAIN` and
`SQUISH_ACCOUNT_ID`, consumed by `run-ci.sh` and read in tests via `serverAccount.js`.

### `tools/sync_features.py`
Copies each Gherkin spec from the `external/feature-specs` submodule into the BDD test case that implements it
(`BDD_TEST_CASES` maps `tst_BDD_Redial` → `Features/call/redial.feature`). The copies are gitignored:
a spec change reaches the desktop tests by bumping the submodule, not by editing a `.feature` here.
Errors out if the submodule is not checked out.

### `tools/gen_translations.py`
Builds the key→text map: parses `Linphone/data/languages/en.ts` (base) overlaid with
`<lang>.ts`, and writes `export var T = {…};` to `currentTranslations.js`. The en-base merge
mirrors the app's fallback (untranslated keys in a language fall back to English). Override the
source dir with `LANG_TS_DIR`. Keep the resolver reading the **same** `.ts` as the build that
produced the AppImage (i.e. the branch commit) — that's what makes rewords harmless.

### `App.cpp` — `LINPHONE_FORCE_LANGUAGE`
`App::initLocale()` honors `LINPHONE_FORCE_LANGUAGE=<code>` to load `<code>.qm` via
`QLocale(code)`. This exists because the CI container ships only `C`/`en_US` locales, so forcing a
language through the OS (`LC_ALL`, `localedef`/`LOCPATH`) does **not** make Qt switch languages.
The var is never set in production. **Changing this file requires rebuilding the AppImage**, and
`App.cpp` has a **clang-format pre-commit hook** — run `clang-format --style=file -i Linphone/core/App.cpp`
or the commit aborts.

### `suites/cross-platform/shared/scripts/squishlib.js`
The matching engine. On this app+Squish build, `waitForObject`/`findAllObjects` cannot select the
custom QML controls by `objectName`/`id`/`text`/stable-`type` (only the top-level window matches by
its exact className; the `_QMLTYPE_NNN` suffixes are volatile per run). So everything is a
**tree walk**: `findAllObjects({"type":"QQuickApplicationWindow"})` as roots, recurse via
`object.children()`, read `o.text`/`o.visible`/`className`. If a future Squish/Qt combo fixes the
matcher, this layer can be simplified — the page objects above it would not change.

[Squish for Qt]: https://www.qt.io/product/quality-assurance/squish
