# Bookmarks

Search your url bookmarks (links).

## Quick start

```sh
go build .
```

Create a links.json file that looks something like this:

```json
[
  {
    "name": "example",
    "url": "https://example.com",
    "tags": ["memes", "hello", "cool"]
  },
  {
    "name": "email",
    "url": "https://hotmail.com",
    "tags": ["email", "business"]
  }
]
```

```sh
# Print all links
./bookmarks

# Print all links where name, url or any tag contains `hello`
./bookmarks hello
```

For interactive search, do

```sh
./interactive
```

For this you need to have [fzf](https://github.com/junegunn/fzf) installed. To open the selected links in a browser, pipe the results to your browser command. E.g. for mac:

```sh
./bookmarks hello | xargs open
./interactive | xargs open
```

TODO: `fzf` isn't used for any fuzzy searching here, is there something more suitable?
