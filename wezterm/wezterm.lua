local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.automatically_reload_config = true


-- 基本設定
config.font = wezterm.font("0xProto Nerd Font")
config.font_size = 11.0
config.default_prog = {"wsl.exe", "-d", "Ubuntu", "--cd", "~"}
config.color_scheme = "AdventureTime"


-- 背景設定
config.background = {
    {
        source = {
            File = "C:\\Users\\TUFGamingB550Plus\\Pictures\\壁紙\\ターミナル\\第六駆逐隊_ターミナル2.jpg",
        },
        hsb = { brightness = 0.8 },
        attachment = "Fixed"
    }
}


-- 外観設定
config.window_decorations = "RESIZE"
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.4
}
config.colors = {
    tab_bar = {
        background = "rgba(0, 0, 0, 0)"
    }
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
    elseif window:leader_is_active() then
        status = "   LEADER   "
        bg_color = "#ae8b2d"
    end

    if status ~= "" then
        window:set_right_status(wezterm.format({
            { Attribute = { Intensity = "Bold" } },
            { Background = { Color = bg_color } },
            { Foreground = { Color = "#FFFFFF" } },
            { Text = status }
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

    local prefix = ""
    if tab.tab_index == 0 then
        prefix = "  "
    end

    return {
        { Text = prefix },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_LEFT_ARROW },
        { Background = { Color = background } },
        { Foreground = { Color = foreground} },
        { Text = title},
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_RIGHT_ARROW },
        { Text = "  " }
    }
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
        action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" })
    },

    -- 横分割(上下に2枚)
    {
        key = '"', -- 修正: '""' から '"' へ変更
        mods = "LEADER|SHIFT",
        action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" })
    },

    -- ペイン移動
    {
        key = "LeftArrow",
        mods = "LEADER",
        action = wezterm.action.ActivatePaneDirection("Left")
    },
    {
        key = "RightArrow",
        mods = "LEADER",
        action = wezterm.action.ActivatePaneDirection("Right")
    },
    {
        key = "DownArrow",
        mods = "LEADER",
        action = wezterm.action.ActivatePaneDirection("Down")
    },
    {
        key = "UpArrow",
        mods = "LEADER",
        action = wezterm.action.ActivatePaneDirection("Up")
    },

    -- リサイズ
    {
        key = "z",
        mods = "LEADER",
        action = wezterm.action.ActivateKeyTable({
            name = "resize_pane",
            one_shot = false
        })
    },

    -- ペイン削除
    {
        key = "x",
        mods = "LEADER",
        action = wezterm.action.CloseCurrentPane({ confirm = true })
    },

    -- タブ名変更
    {
        key = "r",
        mods = "LEADER",
        action = wezterm.action.PromptInputLine({
            description = "新しいタブ名を入力してください",
            action = wezterm.action_callback(function (window, pane, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end)
        })
    },

    -- 画面フルスクリーン切り替え
    {
        key = "Enter",
        mods = "ALT",
        action = wezterm.action.ToggleFullScreen
    },

    -- コピーモード
    {
        key = "[",
        mods = "LEADER",
        action = wezterm.action.ActivateCopyMode
    },

    -- コピー
    {
        key = "c",
        mods = "CTRL",
        action = wezterm.action.CopyTo("Clipboard")
    },

    -- ペースト
    {
        key = "v",
        mods = "CTRL",
        action = wezterm.action.PasteFrom("Clipboard")
    },

    -- フォントサイズ切り替え
    {
        key = ";",
        mods = "CTRL",
        action = wezterm.action.IncreaseFontSize
    },
    {
        key = "-",
        mods = "CTRL",
        action = wezterm.action.DecreaseFontSize
    },
    {
        key = "0",
        mods = "CTRL",
        action = wezterm.action.ResetFontSize
    },

    -- タブ切り替え
    {
        key = "1",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(0)
    },
    {
        key = "2",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(1)
    },
    {
        key = "3",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(2)
    },
    {
        key = "4",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(3)
    },
    {
        key = "5",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(4)
    },
    {
        key = "6",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(5)
    },
    {
        key = "7",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(6)
    },
    {
        key = "8",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(7)
    },
    {
        key = "9",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(-1)
    },
}

config.key_tables = {
    resize_pane = {
        { key = "LeftArrow", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
        { key = "RightArrow", action = wezterm.action.AdjustPaneSize({"Right", 1}) },
        { key = "DownArrow", action = wezterm.action.AdjustPaneSize({"Down", 1}) },
        { key = "UpArrow", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },
        { key = "Escape", action = "PopKeyTable" }
    }
    -- copy_mode はデフォルトを使用するため削除
}

return config