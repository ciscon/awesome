pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")

if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
                    title = "Oops, there were errors during startup!",
                    text = awesome.startup_errors })
end

do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
                             if in_error then return end
                             in_error = true

                             naughty.notify({ preset = naughty.config.presets.critical,
                                              title = "Oops, an error happened!",
                                              text = tostring(err) })
                             in_error = false
   end)
end

beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/ciscon-custom/theme.lua")

terminal = "terminal"
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
menubar.show_categories = false
screenshot_cmd = "screenshot"
browser_cmd = "browser"
browser_private_cmd = "browser --incognito --private"

modkey = "Mod4"

awful.layout.layouts = {
   awful.layout.suit.tile,
   awful.layout.suit.tile.top,
   awful.layout.suit.fair,
   awful.layout.suit.max,
   awful.layout.suit.floating,
}


local spacerempty = wibox.widget{
   markup = ' ',
   align  = 'center',
   valign = 'center',
   widget = wibox.widget.textbox
}


local function tag_view_nonempty_fixed(direction, s)
   s = s or awful.screen.focused()
   local idx = s.selected_tag.index
   for i = 1, #s.tags do
      local t = s.tags[(idx - 1 + i * direction) % #s.tags + 1]
      if t and #t:clients() > 0 then
         t:view_only()
         return
      end
   end
end


local taglist_buttons = gears.table.join(
   awful.button({ }, 1, function(t) t:view_only() end),
   awful.button({ modkey }, 1, function(t)
         if client.focus then
            client.focus:move_to_tag(t)
         end
   end),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function(t)
         if client.focus then
            client.focus:toggle_tag(t)
         end
   end),
   awful.button({ }, 4, function() tag_view_nonempty_fixed(1) end),
   awful.button({ }, 5, function() tag_view_nonempty_fixed(-1) end),
   awful.button({ modkey }, 4,  function(t) awful.tag.viewnext(t.screen) end),
   awful.button({ modkey }, 5,  function(t) awful.tag.viewprev(t.screen) end)
)


local tasklist_buttons = gears.table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            -- set the minimized client to last slave                                                                                          
            local tag = awful.screen.focused().selected_tag
            local cnum=#tag:clients()
            awful.client.swap.byidx(cnum+1,c)
            awful.client.setslave(c)
            c.minimized = true
         else
            c:emit_signal(
               "request::activate",
               "tasklist",
               {raise = true}
            )
         end
   end),
   awful.button({ }, 4, function ()
         awful.client.focus.byidx(1)
   end),
   awful.button({ }, 5, function ()
         awful.client.focus.byidx(-1)
   end)
)


-- local markup = lain.util.markup
local mytextclock = wibox.widget.textclock("%a %b %m-%d-%y %H:%M ")
mytextclock.font = beautiful.taglist_font

local loadcolor="#81a2be"
local loadlabelcolor=beautiful.tasklist_fg_minimize

-- load avg
local loadavg_widget = wibox.widget {
   widget = wibox.widget.textbox
}
local loadavgcmd = 
[[sh -c '
while :; do
  cat /proc/loadavg||exit
  sleep 5
  done
']]
awful.spawn.with_line_callback(loadavgcmd, {
  stdout=function (line)
    if line ~= nil then
      loadavg_widget:set_markup('<span foreground="'..loadlabelcolor..'">Load:</span><span foreground="'..loadcolor..'">'..line:match"^(%S+)"..'</span>')
    end
  end
})


-- gpu load widget
local gpuload_widget = wibox.widget {
  widget = wibox.widget.textbox
}
local gpuloadcmd = 
[[sh -c '
while :; do
  cat /sys/class/drm/card0/device/gpu_busy_percent||exit
  sleep 5
  done
']]
awful.spawn.with_line_callback(gpuloadcmd, {
  stdout=function (line)
    if line ~= nil then
      gpuload_widget:set_markup('<span foreground="'..loadlabelcolor..'">GPU:</span><span foreground="'..loadcolor..'">'..line..'</span>')
    end
  end
})

local trayscreen = screen[1]
local systray = wibox.widget.systray()
local tray = wibox.widget {
   systray,
   layout = wibox.container.margin,
   margins = beautiful.border_width+1,
   valign = 'center',
   halign = 'center',
   widget = wibox.container.place,
}


local function set_wallpaper(s)
   -- Wallpaper
   if beautiful.wallpaper then
      local wallpaper = beautiful.wallpaper
      -- If wallpaper is a function, call it with the screen
      if type(wallpaper) == "function" then
         wallpaper = wallpaper(s)
      end
      local offset={}
      offset.y=beautiful.menu_height/2
      gears.wallpaper.maximized(wallpaper, s, true, offset)
   end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)                                                        
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
      set_wallpaper(s)

      awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 " }, s, awful.layout.layouts[1])

      s.mypromptbox = awful.widget.prompt()
      s.mylayoutbox = awful.widget.layoutbox(s)
      s.mylayoutbox:buttons(
         gears.table.join(
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc( 1) end),
            awful.button({ }, 5, function () awful.layout.inc(-1) end)
         )
      )

      s.mytaglist = awful.widget.taglist {
         screen  = s,
         filter  = awful.widget.taglist.filter.all,
         buttons = taglist_buttons
      }

      local taglist = wibox.widget {
         s.mytaglist,
         layout  = wibox.layout.fixed.horizontal,
         widget = wibox.container.place,
      }

      s.mytasklist = awful.widget.tasklist {
         screen  = s,
         buttons = tasklist_buttons,
         -- filter  = awful.widget.tasklist.filter.currenttags
         filter      = function (c,s)
            local result
            result=awful.widget.tasklist.filter.focused(c,s)
            if not result then
               result=awful.widget.tasklist.filter.minimizedcurrenttags(c,s)
            end
            return result
         end
      }

      s.mywibox = awful.wibar({
        position = "top",
        height = beautiful.menu_height, -- bar height
        screen = s })

      s.mywibox:setup {

         layout = wibox.layout.align.horizontal,
         { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            taglist,
            spacerempty,
            s.mylayoutbox,
            s.mypromptbox,
            spacerempty,
         },
         s.mytasklist, -- Middle widget
         { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacerempty,
            spacerempty,
            spacerempty,
            loadavg_widget,
            spacerempty,
            gpuload_widget,
            spacerempty,
            spacerempty,
            spacerempty,
            mytextclock,
            spacerempty,
            tray,
         },
      }
end)

root.buttons(gears.table.join(
                awful.button({ }, 4, awful.tag.viewnext),
                awful.button({ }, 5, awful.tag.viewprev)
))

local function reset_tag()
   local t = awful.screen.focused().selected_tag
   if not t then return end
   t.master_count=1
   t.column_count=1
   t.master_width_factor=0.5
   for _, c in ipairs(t:clients()) do
      if c.minimized == true then c.minimized=false end
      if c.maximized == true then c.maximized=false end
      if c.floating == true then c.floating =false end
   end
end


globalkeys = gears.table.join(
   awful.key({ modkey,           }, "Tab", awful.tag.history.restore,
      {description = "go back", group = "tag"}),

   awful.key({ modkey,           }, "j",
      function ()
         awful.client.focus.byidx( 1)
      end,
      {description = "focus next by index", group = "client"}
   ),
   awful.key({ modkey,           }, "k",
      function ()
         awful.client.focus.byidx(-1)
      end,
      {description = "focus previous by index", group = "client"}
   ),
   awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
      {description = "show main menu", group = "awesome"}),

   --tag movement
   awful.key({ modkey,  "Control" }, "h",   awful.tag.viewprev,
      {description = "view previous", group = "tag"}),
   awful.key({ modkey,  "Control" }, "l",  awful.tag.viewnext,
      {description = "view next", group = "tag"}),
   awful.key({ modkey, "Shift" }, "h",   function () tag_view_nonempty_fixed(-1) end),
   awful.key({ modkey, "Shift" }, "l",   function () tag_view_nonempty_fixed(1) end),

   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
      {description = "swap with next client by index", group = "client"}),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
      {description = "swap with previous client by index", group = "client"}),
   awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
      {description = "jump to urgent client", group = "client"}),
   awful.key({ modkey,           }, "Escape",
      function ()
         awful.client.focus.history.previous()
         if client.focus then
            client.focus:raise()
         end
      end,
      {description = "go back", group = "client"}),

   awful.key({ modkey },            "x",     function () awful.spawn(xscreensaver_cmd) end,
      {description = "screensaver", group = "launcher"}),
   awful.key({ modkey, "Shift" },            "x",     function () awful.spawn(xscreensaver_lock_cmd) end,
      {description = "screensaver lock", group = "launcher"}),
   awful.key({ modkey,           }, "g", function () awful.spawn(browser_cmd) end,
      {description = "open a terminal", group = "launcher"}),
   awful.key({ modkey,           }, "s", function () awful.spawn(screenshot_cmd) end,
      {description = "take screenshot", group = "launcher"}),
   awful.key({ modkey, "Shift"          }, "g", function () awful.spawn(browser_private_cmd) end,
      {description = "open a terminal", group = "launcher"}),
   awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
      {description = "open a terminal", group = "launcher"}),
   awful.key({ modkey, "Control" }, "r", awesome.restart,
      {description = "reload awesome", group = "awesome"}),
   awful.key({ modkey, "Shift"   }, "q", awesome.quit,
      {description = "quit awesome", group = "awesome"}),
   awful.key({ modkey,           }, "l",     function () 
         local master_c=awful.client.getmaster()
         if master_c and master_c.width and master_c.size_hints and master_c.size_hints.max_width then
            if master_c.width < master_c.size_hints.max_width then
               awful.tag.incmwfact( 0.05)
            end
         else
            awful.tag.incmwfact( 0.05)
         end
   end,
      {description = "increase master width factor", group = "layout"}),
   awful.key({ modkey,           }, "h",     function () 
         local master_c=awful.client.getmaster()
         if master_c and master_c.width and master_c.size_hints and master_c.size_hints.min_width then
            if master_c.width > master_c.size_hints.min_width then
               awful.tag.incmwfact( -0.05)
            end
         else
            awful.tag.incmwfact( -0.05)
         end
   end,
      {description = "decrease master width factor", group = "layout"}),
   awful.key({ modkey }, "i",     function () awful.tag.incnmaster( 1, nil, true) end,
      {description = "increase the number of master clients", group = "layout"}),
   awful.key({ modkey }, "d",     function () awful.tag.incnmaster(-1, nil, true) end,
      {description = "decrease the number of master clients", group = "layout"}),
   awful.key({ modkey, "Shift" }, "i",     function () awful.tag.incncol( 1, nil, true)    end,
      {description = "increase the number of columns", group = "layout"}),
   awful.key({ modkey, "Shift" }, "d",     function () awful.tag.incncol(-1, nil, true)    end,
      {description = "decrease the number of columns", group = "layout"}),

   awful.key({ modkey,           }, "r",     function () reset_tag() end,
      {description = "reset", group = "layout"}),
   awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
      {description = "select next", group = "layout"}),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
      {description = "select prev", group = "layout"}),
   awful.key({ modkey, }, "m", function (c)
         if c then
           client.focus = c
           c:raise()
         end
         awful.layout.set(awful.layout.suit.max)
   end,
      {description = "max layout, focus current client", group = "layout"}),
   awful.key({ modkey, }, "t", function () awful.layout.set(awful.layout.suit.tile) end,
      {description = "vtile layout", group = "layout"}),
   awful.key({ modkey, "Shift" }, "t", function () awful.layout.set(awful.layout.suit.tile.top) end,
      {description = "htile layout", group = "layout"}),
   awful.key({ modkey, "Control" }, "t", function () awful.layout.set(awful.layout.suit.fair) end,
      {description = "fair layout", group = "layout"}),
   awful.key({ modkey, }, "f", function () awful.layout.set(awful.layout.suit.float) end,
      {description = "float layout", group = "layout"}),

   awful.key({ modkey, "Shift" }, "n",
      function ()
         local c = awful.client.restore()
         if c then
            c:emit_signal(
               "request::activate", "key.unminimize", {raise = true}
            )
         end
      end,
      {description = "restore minimized", group = "client"}),

   -- awful.key({ modkey },            "p",     function () awful.screen.focused().mypromptbox:run() end,
   awful.key({ modkey },            "p",     function () menubar.show()  end,
      {description = "run prompt", group = "launcher"})
)

clientkeys = gears.table.join(
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
      {description = "close", group = "client"}),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
      {description = "toggle floating", group = "client"}),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
      {description = "move to master", group = "client"}),

   --screen functions
   -- awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
   -- {description = "move to screen", group = "client"}),
   awful.key({ modkey, }, ".", function () awful.screen.focus_relative( 1) end,
      {description = "focus the next screen", group = "screen"}),
   awful.key({ modkey, }, ",", function () awful.screen.focus_relative(-1) end,
      {description = "focus the previous screen", group = "screen"}),

   awful.key({ modkey,           }, "n",
      function (c)
         -- set the minimized client to last slave
         local tag = awful.screen.focused().selected_tag
         local cnum=#tag:clients()
         awful.client.swap.byidx(cnum+1,c)
         awful.client.setslave(c)
         c.minimized = true
      end ,
      {description = "minimize", group = "client"})
)

for i = 1, 9 do
   globalkeys = gears.table.join(globalkeys,
                                 awful.key({ modkey }, "#" .. i + 9,
                                    function ()
                                       local screen = awful.screen.focused()
                                       local tag = screen.tags[i]
                                       if tag then
                                          tag:view_only()
                                       end
                                    end,
                                    {description = "view tag #"..i, group = "tag"}),
                                 awful.key({ modkey, "Control" }, "#" .. i + 9,
                                    function ()
                                       local screen = awful.screen.focused()
                                       local tag = screen.tags[i]
                                       if tag then
                                          awful.tag.viewtoggle(tag)
                                       end
                                    end,
                                    {description = "toggle tag #" .. i, group = "tag"}),
                                 awful.key({ modkey, "Shift" }, "#" .. i + 9,
                                    function ()
                                       if client.focus then
                                          local tag = client.focus.screen.tags[i]
                                          if tag then
                                             client.focus:move_to_tag(tag)
                                          end
                                       end
                                    end,
                                    {description = "move focused client to tag #"..i, group = "tag"}),
                                 awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                                    function ()
                                       if client.focus then
                                          local tag = client.focus.screen.tags[i]
                                          if tag then
                                             client.focus:toggle_tag(tag)
                                          end
                                       end
                                    end,
                                    {description = "toggle focused client on tag #" .. i, group = "tag"})
   )
end

clientbuttons = gears.table.join(
   awful.button({ }, 1, function (c)
         c:emit_signal("request::activate", "mouse_click", {raise = true})
   end),
   awful.button({ modkey }, 1, function (c)
         c:emit_signal("request::activate", "mouse_click", {raise = true})
         awful.mouse.client.move(c)
   end),
   awful.button({ modkey }, 3, function (c)
         c:emit_signal("request::activate", "mouse_click", {raise = true})
         if c.floating then
           c.size_hints_honor=true
           awful.mouse.client.resize(c)
         end
   end)
)

-- always disable size hints when coming out of mouse resize (floating only)
awful.mouse.resize.add_leave_callback(function(c, args)
  c.size_hints_honor=false
end, "mouse.resize")


root.keys(globalkeys)

awful.rules.rules = {

   { rule = { },
     properties = { border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    size_hints_honor = false, --urxvt empty space issue
                    focus = awful.client.focus.filter,
                    raise = true,
                    keys = clientkeys,
                    buttons = clientbuttons,
                    screen = awful.screen.preferred,
                    placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
   },

   -- { 
   --    rule_any = {
   --       instance = {
   --          "gimp",
   --       },
   --       class = {
   --          "gimp",
   --       },
   --       name = {
   --       },
   --       role = {
   --       }
   --    }, properties = { floating = true }},

   { rule = { class = "Thunderbird" },
     properties = { screen = screen.count(), tag = " 1 " } },
   { rule = { class = "discord" },
     properties = { screen = 1, tag = " 7 " } },
   { rule = { class = "Hexchat" },
     properties = { screen = 1, tag = " 8 " } },
   { rule = { class = "Deadbeef" },
     properties = { screen = 1, tag = " 9 " } },
   { rule = { class = "steam" },
     properties = { screen = 1, tag = " 5 " } },
   { rule = { class = "Steam" },
     properties = { screen = 1, tag = " 5 " } },
   { rule = { name = "Steam" },
     properties = { screen = 1, tag = " 5 " } },
   { rule = { class = "steamwebhelper" },
     properties = { screen = 1, tag = " 5 " } },
   { rule = { class = "Slack" },
     properties = { screen = 1, tag = " 6 " } },
   { rule_any = { class = { "youtubemusic" } },
     properties = { screen = 1, tag = " 9 ", floating = false } },
   { rule_any = { class = { "mpv" } },
     properties = { ontop = true } },
   { rule_any = { class = { "Workspacesclient" } },
     properties = { floating = true } },
}


client.connect_signal("manage", function (c)
                         if not awesome.startup then awful.client.setslave(c) end
                         if awesome.startup
                            and not c.size_hints.user_position
                            and not c.size_hints.program_position then
                            awful.placement.no_offscreen(c)
                         end
end)


client.connect_signal("mouse::enter", function(c)
                         c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

screen.connect_signal("arrange", function (s)
                         local only_one = #s.tiled_clients == 1
                         for _, c in pairs(s.clients) do
                            if only_one and not c.floating or c.maximized or c.fullscreen or s.selected_tag.layout.name == "max"
                            then
                               c.border_width = 0
                            else
                               c.border_width = beautiful.border_width
                            end
                         end
end)
