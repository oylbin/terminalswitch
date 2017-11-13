# Terminal Switch Script

Prerequests:

1. MacOS, system language is set to "English".
2. in Terminal Preferences, "Profiles - Window - Title", select "TTY name". This
is to ensure each terminal window has a different title name.

Usage:

1. install [FastScripts.app](https://red-sweater.com/fastscripts/)
2. install "terminal.applescript" to "~/Library/Scripts/"
3. set a Shortcut (such as ⌥C) in FastScripts Preferences to invoke "terminal.applescript"

When "terminal.applescript" is invoked:

1. if there is no Terminal.app windows exists, a new Terminal.app window will be opened.
2. if there is only one Terminal.app window exists, activate and switch to it.
3. if there are multiple Terminal.app windows exists, circulate between these windows.

