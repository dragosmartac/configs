# configs

My macOS setup uses iTerm2, tmux 3.6a, and Homebrew ranger 1.9.4.


### Ranger Photo Preview
The scripts in `scripts/ranger_photo_preview/` make JPEG and HEIC previews work inside tmux:

- `scope.sh` uses macOS `sips` to create cached JPEG thumbnails capped at 800 pixels and under 500 KB. Other file types use ranger's standard preview script.
- `iterm2_tmux.py` enables tmux passthrough regardless of `TERM`, fits images to the preview pane, and explicitly clears old previews to prevent leftover image fragments.
- `ranger-session.sh` gives each ranger session a private temporary cache directory that is removed when ranger exits.

Install the scripts (back up any existing versions first):

```sh
mkdir -p ~/.config/ranger/plugins
install -m 755 scripts/ranger_photo_preview/scope.sh ~/.config/ranger/scope.sh
install -m 644 scripts/ranger_photo_preview/iterm2_tmux.py ~/.config/ranger/plugins/iterm2_tmux.py
install -m 755 scripts/ranger_photo_preview/ranger-session.sh ~/.config/ranger/ranger-session.sh
```

Cache directories are created under macOS’s $TMPDIR, with names like ranger-photo-preview.A1B2C3D4.
