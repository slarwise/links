package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"slices"
	"strings"
)

type Link struct {
	Name string   `json:"name"`
	Url  string   `json:"url"`
	Tags []string `json:"tags"`
}

func main() {
	flag.Usage = printUsage
	flag.Parse()

	bytes, err := os.ReadFile("links.json")
	if err != nil {
		logError("Failed to read ./links.json: %s", err.Error())
		os.Exit(1)
	}
	var links []Link
	if err := json.Unmarshal(bytes, &links); err != nil {
		logError("Failed to parse ./links.json: %s", err.Error())
		os.Exit(1)
	}

	if len(os.Args) == 2 {
		query := os.Args[1]
		links = slices.DeleteFunc(links, func(link Link) bool {
			return !linkMatchesQuery(link, query)
		})
	}
	for _, link := range links {
		fmt.Println(link.Url)
	}
}

func printUsage() {
	fmt.Printf(`Usage: %s [QUERY]
    QUERY: a string to search links with%s`,
		os.Args[0],
		"\n",
	)
}

func linkMatchesQuery(link Link, query string) bool {
	words := []string{link.Name, link.Url}
	words = append(words, link.Tags...)
	for _, word := range words {
		if strings.Contains(word, query) {
			return true
		}
	}
	return false
}

func logError(format string, args ...any) {
	if !strings.HasSuffix(format, "\n") {
		format = format + "\n"
	}
	format = "ERROR: " + format
	fmt.Fprintf(os.Stderr, format, args...)
}
