local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.automatically_reload_config = true

-- 基本設定
config.font_size = 11.0
config.default_prog = { "wsl.exe", "-d", "Ubuntu", "--cd", "~" }
config.color_scheme = "AdventureTime"
config.initial_cols = 160
config.initial_rows = 45
config.freetype_load_flags = "NO_HINTING"
config.freetype_load_target = "HorizontalLcd"
config.freetype_render_target = "HorizontalLcd"
config.front_end = "WebGpu"
config.text_background_opacity = 1.0
config.font = wezterm.font("0xProto Nerd Font", { weight = "Medium" })

-- 背景設定
config.background = {
	{
		source = {
			File = "C:\\Users\\TUFGamingB550Plus\\Pictures\\壁紙\\ターミナル\\ハーラちゃん.png",
		},
		hsb = { brightness = 0.2 },
		attachment = "Fixed",
	},
}

-- 外観設定
config.window_decorations = "RESIZE"
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.4,
}
config.colors = {
	tab_bar = {
		background = "rgba(0, 0, 0, 0)",
	},
}

-- 現在のモードの状態を表示
wezterm.on("update-right-status", function(window, pane)
	local status = ""
	local bg_color = "#ae8b2d"
	local name = window:active_key_table()

	if name == "resize_pane" then
		status = "   RESIZE   "
		bg_color = "#4fad2d"
	elseif name == "copy_mode" then
		status = "  COPY  "
		bg_color = "#2d4fad"
	elseif name == "pane_selection" then
		status = " PANE SELECT "
		bg_color = "#ad2d8f"
	elseif window:leader_is_active() then
		status = "   LEADER   "
		bg_color = "#ae8b2d"
	end

	if status ~= "" then
		window:set_right_status(wezterm.format({
			{ Attribute = { Intensity = "Bold" } },
			{ Background = { Color = bg_color } },
			{ Foreground = { Color = "#FFFFFF" } },
			{ Text = status },
		}))
	else
		window:set_right_status("")
	end
end)

local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#5c6d74"
	local foreground = "#FFFFFF"
	local edge_background = "none"

	if tab.is_active then
		background = "#ae8b2d"
		foreground = "#FFFFFF"
	end

	local edge_foreground = background
	local title = tab.tab_title

	-- 追加: コピーモード等で自動的に設定されるタイトルが含まれる場合は無視する
	if title and title:find("Copy mode") then
		title = nil
	end

	if not title or #title == 0 then
		title = "Ubuntu"
	end
	title = " " .. wezterm.truncate_right(title, max_width - 1) .. " "

	local items = {}

	if tab.tab_index == 0 then
		table.insert(items, { Background = { Color = "none" } })
		table.insert(items, { Text = "   " })
	end

	table.insert(items, { Background = { Color = edge_background } })
	table.insert(items, { Foreground = { Color = edge_foreground } })
	table.insert(items, { Text = SOLID_LEFT_ARROW })
	table.insert(items, { Background = { Color = background } })
	table.insert(items, { Foreground = { Color = foreground } })
	table.insert(items, { Text = title })
	table.insert(items, { Background = { Color = edge_background } })
	table.insert(items, { Foreground = { Color = edge_foreground } })
	table.insert(items, { Text = SOLID_RIGHT_ARROW })
	table.insert(items, { Text = "  " })

	return items
end)

config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500

-- Leader設定 Ctrl + q (待機時間 2000ms)
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

config.keys = {
	-- 縦分割(左右に2枚)
	{
		key = "%",
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},

	-- 横分割(上下に2枚)
	{
		key = '"', -- 修正: '""' から '"' へ変更
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- ペイン移動
	{
		key = "LeftArrow",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "RightArrow",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "DownArrow",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "UpArrow",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},

	-- リサイズ
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.ActivateKeyTable({
			name = "resize_pane",
			one_shot = false,
		}),
	},

	-- ペイン削除
	{
		key = "x",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},

	-- タブ名変更
	{
		key = "r",
		mods = "LEADER",
		action = wezterm.action.PromptInputLine({
			description = "新しいタブ名を入力してください",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- 画面フルスクリーン切り替え
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.ToggleFullScreen,
	},

	-- コピーモード
	{
		key = "[",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},

	-- ペイン移動モード
	{
		key = "m",
		mods = "LEADER",
		action = wezterm.action.ActivateKeyTable({
			name = "pane_selection",
			one_shot = false,
		}),
	},

	-- ペースト
	{
		key = "v",
		mods = "CTRL",
		action = wezterm.action.PasteFrom("Clipboard"),
	},

	-- フォントサイズ切り替え
	{
		key = ";",
		mods = "CTRL",
		action = wezterm.action.IncreaseFontSize,
	},
	{
		key = "-",
		mods = "CTRL",
		action = wezterm.action.DecreaseFontSize,
	},
	{
		key = "0",
		mods = "CTRL",
		action = wezterm.action.ResetFontSize,
	},

	-- タブ切り替え
	{
		key = "1",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(0),
	},
	{
		key = "2",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(1),
	},
	{
		key = "3",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(2),
	},
	{
		key = "4",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(3),
	},
	{
		key = "5",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(4),
	},
	{
		key = "6",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(5),
	},
	{
		key = "7",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(6),
	},
	{
		key = "8",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(7),
	},
	{
		key = "9",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(-1),
	},
	-- 右のタブへ移動
	{
		key = "RightArrow",
		mods = "LEADER",
		action = wezterm.action.ActivateTabRelative(1),
	},
	-- 左のタブへ移動
	{
		key = "LeftArrow",
		mods = "LEADER",
		action = wezterm.action.ActivateTabRelative(-1),
	},

	-- コマンドパレット
	{
		key = "p",
		mods = "LEADER",
		action = wezterm.action.ActivateCommandPalette,
	},

	-- PowerShellを新しいタブで開く
	{
		key = "p",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local new_tab, new_pane, new_window = window:mux_window():spawn_tab({
				args = { "powershell.exe" },
			})
			new_tab:set_title("PowerShell")
		end),
	},
}

config.key_tables = {
	resize_pane = {
		{ key = "h", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
		{ key = "l", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },
		{ key = "k", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },
		{ key = "j", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},

	pane_selection = {
		{ key = "h", action = wezterm.action.ActivatePaneDirection("Left") },
		{ key = "j", action = wezterm.action.ActivatePaneDirection("Down") },
		{ key = "k", action = wezterm.action.ActivatePaneDirection("Up") },
		{ key = "l", action = wezterm.action.ActivatePaneDirection("Right") },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},

	copy_mode = {
		-- 移動
		{ key = "h", mods = "NONE", action = wezterm.action.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = wezterm.action.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = wezterm.action.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = wezterm.action.CopyMode("MoveRight") },
		-- 最初と最後に移動
		{ key = "^", mods = "NONE", action = wezterm.action.CopyMode("MoveToStartOfLineContent") },
		{ key = "$", mods = "SHIFT", action = wezterm.action.CopyMode("MoveToEndOfLineContent") },
		-- 左端に移動
		{ key = "0", mods = "NONE", action = wezterm.action.CopyMode("MoveToStartOfLine") },
		{ key = "o", mods = "NONE", action = wezterm.action.CopyMode("MoveToSelectionOtherEnd") },
		{ key = "O", mods = "NONE", action = wezterm.action.CopyMode("MoveToSelectionOtherEndHoriz") },
		--
		{ key = ";", mods = "NONE", action = wezterm.action.CopyMode("JumpAgain") },
		-- 単語ごと移動
		{ key = "w", mods = "NONE", action = wezterm.action.CopyMode("MoveForwardWord") },
		{ key = "b", mods = "NONE", action = wezterm.action.CopyMode("MoveBackwardWord") },
		{ key = "e", mods = "NONE", action = wezterm.action.CopyMode("MoveForwardWordEnd") },
		-- ジャンプ機能 t f
		{ key = "t", mods = "NONE", action = wezterm.action.CopyMode({ JumpForward = { prev_char = true } }) },
		{ key = "f", mods = "NONE", action = wezterm.action.CopyMode({ JumpForward = { prev_char = false } }) },
		{ key = "T", mods = "NONE", action = wezterm.action.CopyMode({ JumpBackward = { prev_char = true } }) },
		{ key = "F", mods = "NONE", action = wezterm.action.CopyMode({ JumpBackward = { prev_char = false } }) },
		-- 一番下へ
		{ key = "G", mods = "NONE", action = wezterm.action.CopyMode("MoveToScrollbackBottom") },
		-- 一番上へ
		{ key = "g", mods = "NONE", action = wezterm.action.CopyMode("MoveToScrollbackTop") },
		-- viweport
		{ key = "H", mods = "NONE", action = wezterm.action.CopyMode("MoveToViewportTop") },
		{ key = "L", mods = "NONE", action = wezterm.action.CopyMode("MoveToViewportBottom") },
		{ key = "M", mods = "NONE", action = wezterm.action.CopyMode("MoveToViewportMiddle") },
		-- スクロール
		{ key = "b", mods = "CTRL", action = wezterm.action.CopyMode("PageUp") },
		{ key = "f", mods = "CTRL", action = wezterm.action.CopyMode("PageDown") },
		{ key = "d", mods = "CTRL", action = wezterm.action.CopyMode({ MoveByPage = 0.5 }) },
		{ key = "u", mods = "CTRL", action = wezterm.action.CopyMode({ MoveByPage = -0.5 }) },
		-- 範囲選択モード
		{ key = "v", mods = "NONE", action = wezterm.action.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "v", mods = "CTRL", action = wezterm.action.CopyMode({ SetSelectionMode = "Block" }) },
		{ key = "V", mods = "NONE", action = wezterm.action.CopyMode({ SetSelectionMode = "Line" }) },
		-- コピー
		{ key = "y", mods = "NONE", action = wezterm.action.CopyTo("Clipboard") },

		-- コピーモードを終了
		{
			key = "Enter",
			mods = "NONE",
			action = wezterm.action.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
		},
		{ key = "Escape", mods = "NONE", action = wezterm.action.CopyMode("Close") },
		{ key = "c", mods = "CTRL", action = wezterm.action.CopyTo("Clipboard") },
		{ key = "q", mods = "NONE", action = wezterm.action.CopyMode("Close") },
	},
}

return config
