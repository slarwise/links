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
go build .
./links
```

Write to filter the links and press enter to open the link. Read `main.go` for the keyboard shortcuts.
