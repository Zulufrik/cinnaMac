# cinnaMac

This isn't a product or a polished installer — it's a snapshot of how my desktop
looks and behaves (BEWARE IT MAY NOT WORK IN YOUR MACHINE). Most of it is just a handful of config files and two small
helper scripts.


 
## One honest limitation

Cinnamon has no real global menu bar. Unfortunately there is no way to get `File`, `Edit`,
`View` living up in the panel the way macOS does it :/. As an aesthetic alternative i tweaked the Calendar applet by just inserting the text on it. That's a limitation of the desktop environment itself.
<img width="407" height="40" alt="image" src="https://github.com/user-attachments/assets/b102884d-98c5-4cc7-b32f-2b1f8c0424b0" />


## The backup

Next to the visual stuff there's a plain-text copy of my Cinnamon preferences. Two small scripts keep it up to date: one saves the current state, the other
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
