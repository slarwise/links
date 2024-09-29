package main

import (
	_ "embed"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	rl "github.com/gen2brain/raylib-go/raylib"
)

//go:embed JetBrainsMonoNerdFont-Medium.ttf
var fontData []byte

func main() {
	flag.Parse()

	homeDir, err := os.UserHomeDir()
	if err != nil {
		logError("Could not find the home directory: %s", err.Error())
		os.Exit(1)
	}
	configPath := filepath.Join(homeDir, ".config", "links.txt")
	bytes, err := os.ReadFile(configPath)
	if err != nil {
		logError("Failed to read %s: %s", configPath, err.Error())
		os.Exit(1)
	}
	links := strings.Split(string(bytes), "\n")
	links = links[0 : len(links)-1]
	filteredLinks := []string{}
	query := ""
	selectedLink := 0
	queryUpdated := true
	blueBg := rl.NewColor(91, 206, 250, 100)
	pinkBg := rl.NewColor(245, 169, 184, 100)
	black := rl.NewColor(0, 0, 0, 255)
	resultsY := 50
	width := 1000
	height := 300
	rectX := 0.075 * float32(width)
	rectWidth := int32(0.85 * float32(width))

	rl.SetTargetFPS(60)
	rl.SetConfigFlags(rl.FlagWindowUndecorated)
	rl.InitWindow(int32(width), int32(height), "Links")
	windowPos := rl.GetWindowPosition()
	rl.SetWindowPosition(int(windowPos.X), 220)
	fontSize := 20
	font := rl.LoadFontFromMemory(".ttf", fontData, 2*int32(fontSize), nil)
	defer rl.CloseWindow()
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.RayWhite)

		rl.DrawRectangle(int32(rectX), 20, rectWidth, 20, blueBg)
		// TODO: Handle holding keys down
		key := rl.GetKeyPressed()
		if key == rl.KeyBackspace {
			if len(query) > 0 {
				query = query[0 : len(query)-1]
				queryUpdated = true
			}
		} else if key == rl.KeyEnter {
			if len(filteredLinks) > 0 {
				url, _, _ := strings.Cut(filteredLinks[selectedLink], " ")
				rl.OpenURL(url)
				os.Exit(0)
			}
		} else if key == rl.KeyDown {
			selectedLink = min(len(filteredLinks)-1, selectedLink+1)
		} else if key == rl.KeyUp {
			selectedLink = max(0, selectedLink-1)
		} else if rl.IsKeyDown(rl.KeyLeftControl) || rl.IsKeyDown(rl.KeyRightControl) {
			switch key {
			case rl.KeyU:
				query = ""
				queryUpdated = true
			case rl.KeyLeftBracket:
				os.Exit(0)
			case rl.KeyJ, rl.KeyN:
				selectedLink = min(len(filteredLinks)-1, selectedLink+1)
			case rl.KeyK, rl.KeyP:
				selectedLink = max(0, selectedLink-1)
			case rl.KeyM:
				if len(filteredLinks) > 0 {
					url, _, _ := strings.Cut(filteredLinks[selectedLink], " ")
					rl.OpenURL(url)
					os.Exit(0)
				}
			}
		} else if rl.IsKeyDown(rl.KeyLeftAlt) || rl.IsKeyDown(rl.KeyRightAlt) {
			switch key {
			case rl.KeyJ, rl.KeyN:
				selectedLink = min(len(filteredLinks)-1, selectedLink+5)
			case rl.KeyK, rl.KeyP:
				selectedLink = max(0, selectedLink-5)
			}
		} else if key >= 39 && key <= 90 {
			if rl.IsKeyDown(rl.KeyLeftShift) || rl.IsKeyDown(rl.KeyRightShift) {
				query += string(key)
				queryUpdated = true
			} else {
				query += strings.ToLower(string(key))
				queryUpdated = true
			}
		}

		rl.DrawTextEx(font, query, rl.NewVector2(rectX, 20), float32(fontSize), 0, black)

		if queryUpdated {
			selectedLink = 0
			filteredLinks = []string{}
			for _, l := range links {
				if strings.Contains(l, query) {
					filteredLinks = append(filteredLinks, l)
				}
			}
		}

		linksToShow := filteredLinks[selectedLink:]
		for i, l := range linksToShow {
			if i == 0 {
				rl.DrawRectangle(int32(rectX), int32(resultsY+i*20), rectWidth, 20, pinkBg)
			}
			rl.DrawTextEx(font, l[:min(70, len(l))], rl.NewVector2(rectX, float32(resultsY+i*20)), float32(fontSize), 0, rl.Black)
		}

		queryUpdated = false
		rl.EndDrawing()
	}
}

func logError(format string, args ...any) {
	if !strings.HasSuffix(format, "\n") {
		format = format + "\n"
	}
	format = "ERROR: " + format
	fmt.Fprintf(os.Stderr, format, args...)
}
