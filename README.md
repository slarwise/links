# Links

Search through your links and open them.

## Quick start

Create `~/.config/links.txt` file that looks something like this:

```
duckduckgo.com search
https://github.com/TechForPalestine/boycott-israeli-tech-companies-dataset
```

Each line starts with the url, and any words after that are labels to help searching. Then run it with

```sh
odin build .
./links
```

Write to filter the links and press enter to open the link. Keybindings:

| Key            | Action       |
| -------------- | ------------ |
| Ctrl-J         | Go down      |
| Ctrl-K         | Go up        |
| Enter, Ctrl-M  | Open link    |
| Ctrl-U         | Clear filter |
| Escape, Ctrl-[ | Exit         |
