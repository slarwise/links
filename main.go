package main

import (
	"encoding/json"
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
	bytes, err := os.ReadFile("links.json")
	if err != nil {
		logError("Failed to read ./links.json: %s", err.Error())
		os.Exit(1)
	}
	var links []Link
	if err := json.Unmarshal(bytes, &links); err != nil {
		logError("Failed to parse ./links.json: %s\n", err.Error())
		os.Exit(1)
	}

	var results []Link
	if len(os.Args) == 2 {
		query := os.Args[1]
		for _, link := range links {
			if strings.Contains(link.Name, query) {
				results = append(results, link)
			} else if strings.Contains(link.Url, query) {
				results = append(results, link)
			} else if slices.ContainsFunc(link.Tags, func(tag string) bool {
				return strings.Contains(tag, query)
			}) {
				results = append(results, link)
			}
		}
	} else {
		results = links
	}
	for _, result := range results {
		fmt.Println(result.Url)
	}
}

func logError(format string, args ...any) {
	if !strings.HasSuffix(format, "\n") {
		format = format + "\n"
	}
	format = "ERROR: " + format
	fmt.Fprintf(os.Stderr, format, args...)
}

func printUsage() {
	fmt.Printf(`Usage: %s QUERY
    QUERY: a string to search urls with%s`,
		os.Args[0],
		"\n",
	)
}
