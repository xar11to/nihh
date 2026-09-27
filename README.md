# xar-nixos-flake

Flake-based reorganization of your existing `configuration.nix` /
`hardware-configuration.nix`, following the folder layout used in
`aelloc/nihh` (https://github.com/aelloc/nihh) — `flake.nix` → `hosts/<name>/`
→ `hosts/shared/` → `packages/`. Nothing about *what* gets configured has
changed, only *where* it lives. Every option value is copied verbatim from
your current config.

## Layout

```
flake.nix                        # inputs (nixpkgs 26.05, home-manager, plasma-manager)
hosts/
  nixos/
    default.nix                  # nixosSystem call, wires up home-manager for xaruto
    configuration.nix            # KDE Plasma, user, keyboard, audio, games mount, steam, fonts
    gpu.nix                      # NVIDIA PRIME offload + i915, udev rules
    hardware-configuration.nix   # untouched hardware scan
  shared/
    default.nix                  # timezone, locale, xserver, allowUnfree, flakes
    bootloader.nix               # systemd-boot (kept as-is — see risk notes)
    network.nix                  # NetworkManager, hostname from specialArgs
packages/
  system.nix                     # full environment.systemPackages list
home-manager/
  xaruto-home.nix                # per-user entry (username, home dir)
  shared.nix                     # imports everything in modules/, sets home.stateVersion
lib/
  folder.nix                     # auto-imports every .nix file in modules/
modules/
  plasma.nix                     # declarative wallpaper via plasma-manager
  weather.nix                    # `pogoda` / `pogoda3` CLI commands for Jizzakh
```

## What got added this round

### home-manager + plasma-manager (wallpaper & Plasma config)

Added `nix-community/home-manager` (pinned to `release-26.05`, matching your
nixpkgs branch) and `nix-community/plasma-manager` on top of it — that's the
project that actually knows how to write KDE's config files declaratively
(`programs.plasma.*`). It's wired into `hosts/nixos/default.nix` as a NixOS
module (`useGlobalPkgs = true`), so `xaruto`'s home config rebuilds together
with the system on `nixos-rebuild switch`.

`modules/plasma.nix` sets `workspace.wallpaper` to
`/home/xaruto/Pictures/wallpaper.jpg` — **that path doesn't exist yet**, drop
your picture there (any format Plasma reads: jpg/png) or change the path to
wherever you keep it. plasma-manager only writes to KDE's config files, it
doesn't manage the image itself.

One real caveat, not a hypothetical one: plasma-manager issue #583 reports
`workspace.wallpaper` silently not re-applying after a Plasma 6.6 point
release until you log out and back in. If your wallpaper doesn't change
right after `nixos-rebuild switch`, that's the first thing to try before
assuming the config is wrong.

plasma-manager can also manage themes, panels, shortcuts, fonts, etc.
(`programs.plasma.*` — see https://nix-community.github.io/plasma-manager/options.html)
if you want to declare more than wallpaper later — `modules/plasma.nix` is
the place to extend.

### Weather for Jizzakh

Being upfront: I checked `aelloc/nihh` for a weather source, since you
mentioned it might have one — it doesn't. Its two custom flake inputs,
`sl` (`aelloc/statline`) and `humble` (`aelloc/humble`), are the repo
author's own personal status-line tool and personal website, unrelated to
weather. I'm not going to imply otherwise.

What I added instead (`modules/weather.nix`) is a `pogoda` / `pogoda3`
command backed by **wttr.in** — a plain-text weather service, no API key,
no account, no rate-limit surprises for personal use:

```
pogoda    # current conditions in Jizzakh, Russian, metric units
pogoda3   # 3-day forecast
```

This is a CLI tool, not a KDE widget. KDE does have a native "Weather
Station" plasma widget (`org.kde.plasma.weather`, part of `kdeplasma-addons`,
using Met.no/NOAA/Environment Canada as backends) — you can add it the
normal way (right-click panel/desktop → *Add Widgets* → search "Weather" →
set location to Jizzakh in its config dialog). I didn't wire it up through
plasma-manager: the widget's own per-instance config keys (weather station
ID, data source) aren't in plasma-manager's documented widget list the way
`kickoff` or `iconTasks` are, and I'd rather tell you that plainly than
guess at config keys that might silently not apply. Once you've set it up
once through the GUI, run `nix run github:nix-community/plasma-manager` — its
`rc2nix` tool — to capture the exact config and I can turn it into a
declarative module properly.

### Fonts for games and missing glyphs

Added to `hosts/nixos/configuration.nix`'s `fonts.packages`:

- **`corefonts`, `vista-fonts`** — the classic Wine/Proton gap: many
  Windows games and launchers hard-depend on Arial, Times New Roman,
  Tahoma, Segoe UI, Calibri. Both are unfree (Microsoft's own font files),
  already covered by `allowUnfree = true` in `hosts/shared/default.nix`.
- **`dejavu_fonts`, `noto-fonts`, `noto-fonts-cjk-sans`, `noto-fonts-emoji`**
  — broad Unicode fallback so missing glyphs (CJK text, symbols, emoji) show
  up as real characters instead of tofu boxes, in games and everywhere else
  (Discord, browsers, Telegram).

If a *specific* game is still missing a font after this (some older titles
ship their own bundled Wine prefix that doesn't see system fonts), the
per-prefix fix is `WINEPREFIX=/path/to/prefix winetricks corefonts` — that's
a manual, one-off step per game prefix, not something to bake into the
system config.

Only one host exists right now (`nixos`), so the `hosts/shared/` split looks
like overkill today — its value shows up the moment you add a second machine
(a work laptop, a server) and only need to write `hosts/<new-host>/configuration.nix`
plus a `default.nix`, reusing everything in `shared/`.

## Migrating your live system

1. `sudo mkdir -p /etc/nixos-flake && sudo cp -r <these files> /etc/nixos-flake`
   (or clone your own git repo there — a flake needs to be a git-tracked
   directory, at least `git add`-ed, even without a remote).
2. Inside that directory: `git init && git add .`
3. `sudo nixos-rebuild switch --flake /etc/nixos-flake#nixos`
   (or `.#nixos` if you're `cd`-ed into the directory).
4. If it builds and boots cleanly, back up `/etc/nixos` and point
   `/etc/nixos` at this flake directory (or just keep rebuilding from wherever
   you cloned it — `/etc/nixos` is not special once you use `--flake`).

`flake.lock` isn't included — run `nix flake lock` once inside the directory
(needs network access) to pin `nixpkgs` to a specific commit. Without it,
each `nixos-rebuild` re-resolves `nixos-26.05` to its current tip.

## Risk assessment

| Step | Risk | Why |
|---|---|---|
| Splitting config into files, same option values | ~2% | Nix module imports are merged, order-independent for distinct attribute sets — this is a refactor, not a behavior change. |
| `flake.lock` not yet generated | ~10% | First `nixos-rebuild` will fetch a live `nixos-26.05` HEAD; if that channel has an unrelated regression at fetch time, your rebuild could pick it up. Run `nix flake lock` and commit it to pin an exact revision — this drops the risk close to 0%. |
| Keeping `systemd-boot` instead of GRUB (unlike the reference repo) | ~1% | Not changed at all here — switching bootloaders on a live EFI system is the single riskiest thing you could do and isn't part of this restructuring. |
| NVIDIA PRIME / i915 config | ~5% | Copied 1:1 from your working `gpu.nix` split. The only way this regresses is a typo during copy — worth a `nixos-rebuild build --flake .#nixos` dry run before `switch`. |
| `/mnt/games` NTFS mount, Steam, KDE Plasma | ~2% | Verbatim copies. |
| Forgetting to `git add` new files before rebuild | ~15% (common gotcha) | Flakes only see files tracked by git (even unstaged is fine, untracked is not). A new file that isn't `git add`-ed will silently be excluded from the build. |
| Adding home-manager for the first time | ~15% | First activation of a *new* home-manager profile on an account that already has its own dotfiles can hit "file already exists" collisions (e.g. an existing `~/.config/kdeglobals`). `home-manager.backupFileExtension` isn't set here, so a collision will make the whole `switch` fail loudly rather than silently overwrite anything — safe failure mode, but expect to possibly need `mv ~/.config/kdeglobals ~/.config/kdeglobals.bak` once on first run. |
| `workspace.wallpaper` pointing at a file that doesn't exist yet | 100% until you add the file | Not a bug — you need to drop an actual image at `/home/xaruto/Pictures/wallpaper.jpg` (or change the path) before this does anything. |
| plasma-manager's `wallpaper` not re-applying after a point release (upstream issue #583) | ~10% | Known, currently-open upstream bug on some Plasma 6.6 builds. Log out/in fixes it when it happens; not something this config can work around. |
| `pogoda`/`pogoda3` (wttr.in) | ~3% | Depends on a third-party free service staying up; no API key/account to misconfigure. If wttr.in is ever down, the command just times out — no other side effects. |
| Added fonts (`corefonts`, `vista-fonts`, Noto/DejaVu) | ~1% | Pure additions, nothing removed or overridden; worst case is a slightly longer first build while they download. |

Overall: this is a low-risk, mechanical reorganization. The only real trap is
the git-tracking gotcha above — always `git add -A` after editing before you
rebuild.

## Recommended community resources (verify against these, don't trust random blog posts blindly)

- **NixOS Wiki — Flakes**: https://wiki.nixos.org/wiki/Flakes — the closest
  thing to canonical docs for the flake mechanism itself.
- **NixOS Wiki — NixOS configuration on Flakes**: https://wiki.nixos.org/wiki/NixOS_configuration_on_flakes
- **NixOS Discourse** (https://discourse.nixos.org) — the most active official
  forum; search before posting, most PRIME/Optimus laptop issues have prior
  threads.
- **r/NixOS** (https://reddit.com/r/NixOS) — good for driver/hardware
  quirks specific to laptop models like yours (Optimus, i915 backlight).
- **nixos.wiki NVIDIA page**: https://wiki.nixos.org/wiki/Nvidia — PRIME
  offload/sync options, known Optimus gotchas.
- **Home Manager manual**: https://nix-community.github.io/home-manager/ —
  for `home.*` and `programs.*` options in general.
- **plasma-manager options reference**: https://nix-community.github.io/plasma-manager/options.html
  — the actual source of truth for what `programs.plasma.*` can do (panels,
  themes, shortcuts, per-app config), beyond the wallpaper wired up here.
- **wttr.in**: https://github.com/chubin/wttr.in — the weather source behind
  `pogoda`/`pogoda3`; its README documents the URL query options (`?lang=`,
  `?M`/`?u` for units, forecast days) if you want to tweak the output.
- **home.nixos.org / NUR (Nix User Repositories)**: https://github.com/nix-community/NUR
  — for packages not in nixpkgs; the reference repo uses this for xray/
  spicetify-nix-style extras.

Avoid copying random `configuration.nix` snippets from unverified gists —
cross-check anything driver- or bootloader-related against the wiki pages
above or the Discourse thread history before applying it.
