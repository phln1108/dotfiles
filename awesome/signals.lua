require('pkgs')
-- local xresources = require("beatiful.xresources")
-- local dpi = xresources.apply_dpi

client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end
    c.shape = gears.shape.rounded_rect
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.minimizebutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Manage titlebar for clients
local function toggle_titlebar(c)
    if c.floating then
        awful.titlebar.show(c)
        c.border_width = beautiful.border_width
    else
        awful.titlebar.hide(c)
        c.border_width = "0"
    end
end

-- Manage bars for fullscreen clients
local function toggle_bars(c)
    if c.fullscreen then
        awful.titlebar.hide(c)
        c.border_width = "0"
        c.screen.mywibox.visible = false
    else
        if c.floating then
            awful.titlebar.show(c)
            c.border_width = beautiful.border_width
        else
            c.border_width = "0"
            awful.titlebar.hide(c)
        end
        c.screen.mywibox.visible = true
    end
end

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

client.connect_signal("property::floating", toggle_titlebar)

client.connect_signal("manage", toggle_bars)
client.connect_signal("focus", toggle_bars)
client.connect_signal("property::floating", toggle_bars)
client.connect_signal("property::fullscreen", toggle_bars)


