# Quickshell

[Quickshell](https://quickshell.org/about/) is a Linux toolkit for developing
components of the desktop like bars, widgets, and lockscreens.

## Development

My quickshell configuration resides in the `quickshell` dotfiles. Everything is
written in [QML](https://quickshell.org/docs/v0.2.0/guide/qml-language/).

## Setting up the language server

If you want to configure quickshell on a new machine and edit the QML code with
a working language server (qmlls), you will need to create an empty `.qmlls.ini`
file in the root `quickshell` config directory (`~/.config/quickshell`). When
quickshell is run for the first time, this file will be overwritten with a
symlink to a managed qmlls configuration.

In essence, just do this:
```sh
touch shared/home/dotfiles/quickshell/.qmlls.ini
```

Once you start (or restart) quickshell, you should be good to edit the QML files
in that same directory with a working language server.

More info: https://quickshell.org/docs/v0.2.0/guide/install-setup/#language-server

