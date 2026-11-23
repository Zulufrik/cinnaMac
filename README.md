# cinnaMac

My personal Cinnamon setup, dressed up to feel like macOS.

This isn't a product or a polished installer — it's a snapshot of how my desktop
looks and behaves, kept here so I don't lose it and so I can rebuild it on a new
machine someday. Most of it is just a handful of config files and two small
helper scripts.

## What it looks like

**The top bar.** A single slim panel across the top, holding only what a Mac menu
bar would: the app launcher on the left, the title of the active window, and the
usual tray on the right — network, sound, battery, notifications and a clock.

**The launcher.** Cinnamenu, arranged as a full-screen grid of large app icons
with no sidebar and no categories. It opens straight into "All applications", so
it behaves more like Launchpad than a traditional menu. `Super + Space` opens it,
the way Spotlight would.

**The clock.** Twelve-hour format, short and quiet: something like
`Mon 24 Nov  3:42 PM`.

**The battery.** Percentage shown next to the icon, because I like knowing.

**The wallpaper.** A slow slideshow cycling through the macOS wallpapers over the
years — Monterey, Ventura, Sonoma — ending on a dark WhiteSur background.

**The login screen.** LightDM with Slick Greeter, a WhiteSur-dark theme and a
small white Apple logo instead of the distro branding.

**The fonts.** SF Pro for window titles and SF Mono Nerd Font for the terminal and
code.

**The icons and cursor.** WhiteSur and WhiteSur-dark throughout, with the matching
WhiteSur cursor set. There's a small script in here that fixes an old inheritance
quirk where the icons kept falling back to Breeze after KDE was removed.

**The Apple logo.** Another small script that draws and installs the white Apple
mark used in the menu and on the greeter.

**The feel.** Window and GTK animations turned off, and `vm.swappiness` lowered.
Not because the machine is slow — I just prefer things to snap instead of glide.

## One honest limitation

Cinnamon has no real global menu bar. There's no way to get `File`, `Edit`,
`View` living up in the panel the way macOS does it, so the window title sits
there instead. That's a limitation of the desktop environment itself, and I
made peace with it.

## The backup

Next to the visual stuff there's a plain-text copy of my Cinnamon preferences, so
the whole look and feel can be put back without clicking through every setting by
hand. Two small scripts keep it up to date: one saves the current state, the other
restores it — the restore asks before it overwrites anything, and can show what it
would do first.

Before anything is saved, a few things are quietly stripped out: command history,
the last night-light location, and my home directory (swapped for a placeholder so
my username never shows up in a public repo). It covers Cinnamon's own settings,
but not the per-applet JSON files or any other part of the system.

## A note on portability

This is a snapshot of one machine, not a template. Cinnamon versions drift, keys
come and go, and extensions and applets have to be installed separately for any
of this to look right. If you're reading this hoping to reproduce it exactly:
good luck, and start with the themes and fonts.

## License

MIT — see `LICENSE`.
