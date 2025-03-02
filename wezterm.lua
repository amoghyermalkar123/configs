-- Pull in the wezterm API
local wezterm = require('wezterm')
local act = wezterm.action

-- This will hold the configuration
local config = wezterm.config_builder()

-- Color scheme and default domain
config.color_scheme = 'kanagawabones'
config.default_domain = 'WSL:Ubuntu-22.04'
-- Font configuratio2
config.font = wezterm.font('Cascadia Code')
config.font_size = 12.0

-- Make inactive panes slightly dimmer
config.inactive_pane_hsb = {
    saturation = 0.7,
    brightness = 0.7,
}
-- Show fancy tab bar but without unnecessary decorations
config.window_decorations = "RESIZE"
config.enable_tab_bar = true
config.use_fancy_tab_bar = true

config.mouse_bindings = {
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'NONE',
        action = act.CompleteSelection 'ClipboardAndPrimarySelection',
    },
}

-- Maximize window on startup
wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

wezterm.on('update-status', function(window, pane)
    local name = window:active_key_table()
    
    -- Format string
    if name then
        window:set_right_status(wezterm.format({
            { Background = { Color = '#eb6f92' }},
            { Foreground = { Color = '#000000' }},
            { Text = '  MODE: ' .. name .. '  ' },
        }))
    else
        -- Clear the status when not in a mode
        window:set_right_status('')
    end
end)

-- Function to create a development layout
local function create_dev_layout(window)
    local main_pane = window:active_pane()
    
    local bottom_pane = main_pane:split {
        direction = 'Bottom',
        size = 0.25, -- 25% of height
    }
    
    local right_pane = main_pane:split {
        direction = 'Left',
        size = 0.30, -- 30% of width
    }
    
    -- Send commands to specific panes
    right_pane:send_text('z /home/amogh/projects/y-zig\n')  -- idle
    right_pane:send_text('lf\n')
    bottom_pane:send_text('z /home/amogh/projects/y-zig\n')  -- test
    
    -- Focus main pane and send commands last
    main_pane:activate()
    main_pane:send_text('z /home/amogh/projects/y-zig && hx .\n')  -- Editor
end

-- Function to create a development layout
local function stop_motion_project(window)
    local main_pane = window:active_pane()
    
    local bottom_pane = main_pane:split {
        direction = 'Bottom',
        size = 0.25, -- 25% of height
    }
    
    local right_pane = main_pane:split {
        direction = 'Left',
        size = 0.30, -- 30% of width
    }
    
    -- Send commands to specific panes
    right_pane:send_text('z /home/amogh/youtube/tldraw-ts-app\n')  -- idle
    right_pane:send_text('lf\n')
    bottom_pane:send_text('z /home/amogh/youtube/tldraw-ts-app\n')  -- test
    
    -- Focus main pane and send commands last
    main_pane:activate()
    main_pane:send_text('z /home/amogh/youtube/tldraw-ts-app && hx .\n')  -- Editor
end

-- Function to create a monitoring layout
local function create_tinker_layout(window)
    local main_pane = window:active_pane()
    
    -- Create a 2x2 grid
    local right_pane = main_pane:split { direction = 'Left', size = 0.2 }
    
    -- Optional: Send commands to each pane
    main_pane:send_text('z /home/amogh/tinkers\n')
    main_pane:send_text('ls\n')
    right_pane:send_text('z /home/amogh/tinkers\n')
    main_pane:activate()
end


config.keys = {
    -- Pane creation and splitting
    {
        key = 'm',
        mods = 'ALT',
        action = act.SplitPane {
            direction = 'Right',
            size = { Percent = 50 },
        },
    },
    {
        key = '\\',
        mods = 'ALT',
        action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },

    -- Pane navigation
    {
        key = 'h',
        mods = 'ALT',
        action = act.ActivatePaneDirection 'Left',
    },
    {
        key = 'l',
        mods = 'ALT',
        action = act.ActivatePaneDirection 'Right',
    },
    {
        key = 'k',
        mods = 'ALT',
        action = act.ActivatePaneDirection 'Up',
    },
    {
        key = 'j',
        mods = 'ALT',
        action = act.ActivatePaneDirection 'Down',
    },
    {
        key = '1',
        mods = 'ALT',
        action = wezterm.action_callback(function(window, pane)
            create_dev_layout(window)
        end),
    },
    {
        key = '2',
        mods = 'ALT',
        action = wezterm.action_callback(function(window, pane)
            stop_motion_project(window)
        end),
    },
    {
        key = '4',
        mods = 'ALT',
        action = wezterm.action_callback(function(window, pane)
            create_tinker_layout(window)
        end),
    },
}

-- Key table for resize mode
config.key_tables = {
    resize_pane = {
        { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
        { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
        { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
        { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
        { key = 'Escape', action = 'PopKeyTable' },
        { key = 'Enter', action = 'PopKeyTable' },
    },
}

-- Add resize mode activation key
table.insert(config.keys, {
    key = 'b',
    mods = 'ALT',
    action = act.ActivateKeyTable {
        name = 'resize_pane',
        one_shot = false,
    },
})


return config
