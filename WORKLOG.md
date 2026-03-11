# Dotfiles Worklog

## Current direction

- Shell base: `bash`
- Dotfiles model: `layer`, not full replacement
- Repo intended install location on normal machines: `~/.dotfiles`
- Current local working copy during setup: `/var/home/ivan/dev/dotfiles`
- Goal: stay close to system defaults while keeping personal shell UX portable across Linux, macOS and WSL

## What is already working

- `install.sh` installs a managed bootstrap block into:
  - `~/.bashrc`
  - `~/.bash_profile`
- `uninstall.sh` removes the managed bootstrap block by default
- `RESTORE_BACKUP=1 ~/.dotfiles/uninstall.sh` restores the original pre-dotfiles shell files
- `ble.sh` is installed and loaded
- `fzf` and `zoxide` are installed in the current Fedora/Distrobox environment
- Prompt is customized in `shell/bashrc.local`
- Prompt fallback for plain Bash now matches the screenshot direction much more closely:
  - time in bright blue
  - `user@host` in muted gray
  - working directory in teal
  - git branch in lime with `±|branch`
  - dirty state in red as `x|`
- Prompt shows container context when inside Distrobox/container:
  - format: `[box:<name>]`
- `shell/starship.toml` was updated to mirror the same prompt palette and structure when `starship` is installed
- `git` completion issue caused by `fzf` overriding it was fixed by explicitly sourcing git completion and re-registering it

## Files that matter

- `install.sh`
- `uninstall.sh`
- `README.md`
- `shell/bashrc.local`
- `shell/bash_profile.local`

## Important architectural decisions

### Layer model

We decided not to replace host shell files with symlinks.

Instead:

- host files stay minimal
- repo adds a managed bootstrap block
- personal config lives in:
  - `~/.dotfiles/shell/bashrc.local`
  - `~/.dotfiles/shell/bash_profile.local`

Why:

- safer across distros and platforms
- keeps behavior closer to default system shell config
- easier to reason about than a full overwrite model

### Uninstall semantics

Current intended behavior:

- default uninstall:
  - remove managed bootstrap block
  - remove `ble.sh`
  - keep later manual edits in host shell files
- `RESTORE_BACKUP=1`:
  - restore `~/.bashrc.pre-dotfiles`
  - restore `~/.bash_profile.pre-dotfiles`
  - remove `ble.sh`

### Package strategy

Current thinking:

- tools like `fzf`, `zoxide`, `bash-completion`: install per system/package manager
- `ble.sh`: auto-installed into `~/.local/share/blesh`

Tradeoff discussed:

- this is not as "system-native" as package-managed tools
- but it is more portable and simpler than vendoring it into the repo

Decision for now:

- keep `ble.sh` as-is

## Problems encountered

### 1. `git` completion was wrong

Symptom:

- `git cl<Tab>` showed files/directories instead of `clone`

Root cause:

- `bash-completion` was not installed
- later, `fzf` path completion overrode the proper `git` completion

Fix applied:

- install `bash-completion`
- source `/usr/share/bash-completion/bash_completion` on Fedora
- source `/usr/share/bash-completion/completions/git`
- explicitly re-register git completion after loading `fzf`

### 2. Completion/menu styling still feels bad

Symptoms:

- completion menu selection still looks ugly
- ghost text and selection visuals do not feel as polished as expected

Current state:

- improved somewhat
- still not considered "finished"

Open question:

- keep tuning `ble.sh`
- reduce custom styling and stay closer to defaults
- or use a more packaged interactive solution later

### 3. `ble.sh` manual tuning caused friction

Examples:

- wrong widget names for movement bindings
- invalid face name `auto_complete_match`
- several iterations just to get completion/menu behavior acceptable

Conclusion discussed:

- architecture is good
- interactive shell UX may not be worth heavy manual micromanagement

### 4. Distrobox completion is missing

Symptom:

- `distrobox-enter dev<Tab>` completes `dev/` as a directory instead of the container name

Root cause:

- no completion for `distrobox-enter` is currently loaded

Status:

- not fixed yet

### 5. Word movement/delete bindings needed manual help

Current added bindings in `bashrc.local`:

- `Ctrl+Left` -> backward by word
- `Ctrl+Right` -> forward by word
- `Ctrl+Backspace` -> delete backward word
- `Ctrl+Delete` -> delete forward word
- `Alt+Backspace` -> kill backward word
- `Alt+d` -> kill forward word

Note:

- if some of these still fail, terminal/desktop may be intercepting them

## User preferences learned

- prefers Bash over fish/zsh as the main base
- wants cross-platform setup, but with maximum conceptual closeness to normal system behavior
- likes ghost text for history suggestions, but does not want shell UX to become IDE-like noise
- expects `Tab` completion to behave like normal shell completion:
  - commands/subcommands first
  - directories/files when appropriate
- liked the old `oh-my-bash` feel, especially prompt/overall shell UX
- does not want the prompt overly washed out or too minimal in the "empty" sense

## Prompt status

Current prompt direction:

- one line
- `HH:MM:SS user@host cwd ±|branch x| ➜`
- container marker `[box:<name>]` when relevant
- same layout intended for both Bash fallback and `starship`

Status:

- much closer to the desired screenshot
- colors were tuned after comparison against the reference image
- still open to terminal-specific fine tuning if the emulator/theme shifts the palette

## Open questions for next session

1. Should we keep tuning `ble.sh`, or reduce customization and stay closer to defaults?
2. Do we want better history search UX via `fzf` on `Ctrl-r`?
3. Do we want to wire proper Distrobox completion?
4. Do we want to simplify the prompt further or keep the current structure?
5. Should package installation be documented more explicitly per OS, or partially automated later?

## Suggested next steps

### Conservative option

- stop tweaking visuals
- keep current setup
- commit the repo
- only fix missing command completions like `distrobox`

### Balanced option

- fix `distrobox` completion
- improve `Ctrl-r` with `fzf`
- stop there

### More opinionated option

- reconsider whether interactive shell UX should use a more packaged layer instead of many `ble.sh` tweaks
- keep the repo architecture, but simplify the UX implementation
