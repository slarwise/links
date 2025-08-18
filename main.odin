package main

import "core:fmt"
import "core:os/os2"
import "core:strings"
import fzf "vendor/fzfraylib"

main :: proc() {
	if err := run(); err != nil {
		fmt.eprintln(err^)
		os2.exit(1)
	}
}

run :: proc() -> (error: ^string) {
	home_dir, err := os2.user_home_dir(context.allocator)
	if err != nil do return new_clone(fmt.tprintf("read home dir: %s", err))

	links_path, err2 := os2.join_path({home_dir, ".config", "links.txt"}, context.allocator)
	if err2 != nil do return new_clone(fmt.tprintf("join filepath to links: %s", err))

	bytes, err3 := os2.read_entire_file(links_path, context.allocator)
	if err3 != nil do return new_clone(fmt.tprintf("read %s: %s", links_path, err))

	links: [dynamic]string
	for line in strings.split_lines(string(bytes)) {
		if line == "" do continue
		append(&links, line)
	}

	keybinds := map[fzf.Key]proc(item: string){}
	keybinds[.ENTER] = open_link
	fzf.run(links[:], keybinds)
	return nil
}

open_link :: proc(item: string) {
	link := strings.fields(item, context.temp_allocator)[0]
	fzf.open_url(link)
}

