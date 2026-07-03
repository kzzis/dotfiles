# 🏠 dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## 🚀 Setup

```sh
brew install chezmoi
chezmoi init --apply <github-user>/dotfiles
brew bundle --file ~/.local/share/chezmoi/Brewfile
```

## 🔁 Syncing changes

`autoCommit` / `autoPush` are enabled in `chezmoi.toml`, so a `re-add` is all it takes.

```sh
dotsync   # alias: chezmoi re-add -v
```
