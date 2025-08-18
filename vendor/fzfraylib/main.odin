package fzfraylib

import "core:fmt"
import "core:math"
import "core:strings"
import "vendor:raylib"

FONT_SIZE :: 18
SPACING :: 0
COLOR_BG :: raylib.WHITE
COLOR_FG :: raylib.BLACK

Layout :: struct {
	width:           int,
	height:          int,
	items_query_y:   int,
	items_matches_y: int,
	items_gutter_x:  int,
	items_text_x:    int,
	query_max_width: int,
	rows:            int,
}

layout: Layout

ONE_CHAR_WIDTH: f32 = 0

font_data := #load("./JetBrainsMonoNerdFont-Medium.ttf")

Key :: union {
	Ctrl_Key,
	Named_Key,
}

Ctrl_Key :: enum {
	CTRL_A,
	CTRL_B,
	CTRL_C,
	CTRL_D,
	CTRL_E,
	CTRL_F,
	CTRL_G,
	CTRL_H,
	CTRL_I,
	CTRL_J,
	CTRL_K,
	CTRL_L,
	CTRL_M,
	CTRL_N,
	CTRL_O,
	CTRL_P,
	CTRL_Q,
	CTRL_R,
	CTRL_S,
	CTRL_T,
	CTRL_U,
	CTRL_V,
	CTRL_W,
	CTRL_X,
	CTRL_Y,
	CTRL_Z,
}

Named_Key :: enum {
	ENTER,
}

open_url :: proc(url: string) {
	raylib.OpenURL(strings.clone_to_cstring(url, context.temp_allocator))
}

init_layout :: proc(width, height: int) {
	layout.width = width
	layout.height = height
	layout.items_query_y = 50
	layout.items_matches_y = layout.items_query_y + 2 * FONT_SIZE
	layout.items_gutter_x = width / 8
	layout.items_text_x = layout.items_gutter_x + 15
	layout.query_max_width = width / 2 - layout.items_text_x
	layout.rows = (height - layout.items_matches_y) / FONT_SIZE
}

run :: proc(
	items: []string,
	keybinds := map[Key]proc(item: string){},
	width := 800,
	height := 600,
) {
	init_layout(width, height)
	using raylib
	SetTargetFPS(60)
	SetConfigFlags({.WINDOW_UNDECORATED})
	InitWindow(i32(layout.width), i32(layout.height), "applinks");defer CloseWindow()
	font := LoadFontFromMemory(
		".ttf",
		raw_data(font_data[:]),
		i32(len(font_data)),
		2 * FONT_SIZE,
		nil,
		0,
	);defer UnloadFont(font)
	ONE_CHAR_WIDTH = MeasureTextEx(font, "a", FONT_SIZE, SPACING).x
	query_sb := strings.builder_make()
	selected_idx := 0
	window_should_close := false
	filtered_items: [dynamic]string
	for item in items do append(&filtered_items, item)

	for !window_should_close {
		defer free_all(context.temp_allocator)

		ctrl_is_held := IsKeyDown(.LEFT_CONTROL) || IsKeyDown(.RIGHT_CONTROL)
		if WindowShouldClose() || (ctrl_is_held && IsKeyDown(.LEFT_BRACKET)) {
			window_should_close = true
		}
		for key, proc_ in keybinds {
			if len(filtered_items) == 0 do break
			selected_item := filtered_items[selected_idx]
			if ctrl_is_held {
				switch key {
				case .CTRL_A:
					if IsKeyPressed(.A) || IsKeyPressedRepeat(.A) do proc_(selected_item)
				case .CTRL_B:
					if IsKeyPressed(.B) || IsKeyPressedRepeat(.B) do proc_(selected_item)
				case .CTRL_C:
					if IsKeyPressed(.C) || IsKeyPressedRepeat(.C) do proc_(selected_item)
				case .CTRL_D:
					if IsKeyPressed(.D) || IsKeyPressedRepeat(.D) do proc_(selected_item)
				case .CTRL_E:
					if IsKeyPressed(.E) || IsKeyPressedRepeat(.E) do proc_(selected_item)
				case .CTRL_F:
					if IsKeyPressed(.F) || IsKeyPressedRepeat(.F) do proc_(selected_item)
				case .CTRL_G:
					if IsKeyPressed(.G) || IsKeyPressedRepeat(.G) do proc_(selected_item)
				case .CTRL_H:
					if IsKeyPressed(.H) || IsKeyPressedRepeat(.H) do proc_(selected_item)
				case .CTRL_I:
					if IsKeyPressed(.I) || IsKeyPressedRepeat(.I) do proc_(selected_item)
				case .CTRL_J, .CTRL_K:
					panic("CTRL_J and CTRL_K are reserved for navigation") // TODO: Should they be reserved?
				case .CTRL_L:
					if IsKeyPressed(.L) || IsKeyPressedRepeat(.L) do proc_(selected_item)
				case .CTRL_M:
					if IsKeyPressed(.M) || IsKeyPressedRepeat(.M) do proc_(selected_item)
				case .CTRL_N:
					if IsKeyPressed(.N) || IsKeyPressedRepeat(.N) do proc_(selected_item)
				case .CTRL_O:
					if IsKeyPressed(.O) || IsKeyPressedRepeat(.O) do proc_(selected_item)
				case .CTRL_P:
					if IsKeyPressed(.P) || IsKeyPressedRepeat(.P) do proc_(selected_item)
				case .CTRL_Q:
					if IsKeyPressed(.Q) || IsKeyPressedRepeat(.Q) do proc_(selected_item)
				case .CTRL_R:
					if IsKeyPressed(.R) || IsKeyPressedRepeat(.R) do proc_(selected_item)
				case .CTRL_S:
					if IsKeyPressed(.S) || IsKeyPressedRepeat(.S) do proc_(selected_item)
				case .CTRL_T:
					if IsKeyPressed(.T) || IsKeyPressedRepeat(.T) do proc_(selected_item)
				case .CTRL_U:
					if IsKeyPressed(.U) || IsKeyPressedRepeat(.U) do proc_(selected_item)
				case .CTRL_V:
					if IsKeyPressed(.V) || IsKeyPressedRepeat(.V) do proc_(selected_item)
				case .CTRL_W:
					if IsKeyPressed(.W) || IsKeyPressedRepeat(.W) do proc_(selected_item)
				case .CTRL_X:
					if IsKeyPressed(.X) || IsKeyPressedRepeat(.X) do proc_(selected_item)
				case .CTRL_Y:
					if IsKeyPressed(.Y) || IsKeyPressedRepeat(.Y) do proc_(selected_item)
				case .CTRL_Z:
					if IsKeyPressed(.Z) || IsKeyPressedRepeat(.Z) do proc_(selected_item)
				}
			} else {
				switch key {
				case .ENTER:
					if IsKeyPressed(.ENTER) || IsKeyPressedRepeat(.ENTER) do proc_(selected_item)

				}
			}
		}
		for {
			if strings.builder_len(query_sb) * int(ONE_CHAR_WIDTH) >= layout.query_max_width do break
			char := GetCharPressed()
			if char == 0 do break
			strings.write_rune(&query_sb, char)
		}
		if IsKeyPressed(.BACKSPACE) || IsKeyPressedRepeat(.BACKSPACE) {
			strings.pop_rune(&query_sb)
		}
		if ctrl_is_held {
			if IsKeyPressed(.U) {
				strings.builder_reset(&query_sb)
			}
			if IsKeyPressed(.J) || IsKeyPressedRepeat(.J) {
				selected_idx = min(selected_idx + 1, len(filtered_items) - 1)
			}
			if IsKeyPressed(.K) || IsKeyPressedRepeat(.K) {
				selected_idx = max(selected_idx - 1, 0)
			}
		}

		clear(&filtered_items)
		for item in items {
			if fuzzy_match(item, strings.to_string(query_sb)) {
				append(&filtered_items, item)
			}
		}
		selected_idx = max(min(selected_idx, len(filtered_items) - 1), 0)

		{
			BeginDrawing();defer EndDrawing()
			ClearBackground(COLOR_BG)
			query_cstring := strings.clone_to_cstring(
				strings.to_string(query_sb),
				context.temp_allocator,
			)
			DrawTextEx(
				font,
				query_cstring,
				{f32(layout.items_text_x), f32(layout.items_query_y)},
				FONT_SIZE,
				SPACING,
				COLOR_FG,
			)

			for idx, row in max(selected_idx - layout.rows / 2, 0) ..< len(filtered_items) {
				if row >= layout.rows do break
				y := f32(layout.items_matches_y + row * FONT_SIZE)
				if idx == selected_idx {
					DrawTextEx(
						font,
						"*",
						{f32(layout.items_gutter_x), y},
						FONT_SIZE,
						SPACING,
						COLOR_FG,
					)
				}
				DrawTextEx(
					font,
					strings.clone_to_cstring(filtered_items[idx]),
					{f32(layout.items_text_x), y},
					FONT_SIZE,
					SPACING,
					COLOR_FG,
				)
			}
		}
	}
}

fuzzy_match :: proc(s, query: string) -> bool {
	// TODO: Make it fancy
	if strings.contains(s, query) do return true
	return false
}

