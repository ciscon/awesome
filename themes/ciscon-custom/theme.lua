--[[

based on blackburn
github.com/lcpz

--]]

local naughty = require("naughty")
local gears = require("gears")
-- local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi

local os = os

local theme                                     = {}
local font_size                                 = 10
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes/ciscon-custom"
theme.wallpaper                                 = theme.dir .. "/wall.png"
theme.systray_icon_spacing                      = dpi(5)
theme.taglist_spacing                           = dpi(0)
theme.font                                      = "Mono Bold " .. dpi(font_size)
theme.taglist_font                              = "Mono Bold " .. dpi(font_size)
theme.useless_gap                               = dpi(2)
theme.gap_single_client                         = false

theme.fg_normal                                 = "#D7D7D7"
theme.fg_focus                                  = "#DE935F"
theme.bg_normal                                 = "#252525"
theme.bg_focus                                  = theme.bg_normal
theme.bg_urgent                                 = "#DE935F50"
theme.border_width                              = dpi(2)
theme.border_normal                             = "#404040"
theme.border_focus                              = "#E0A57C"
theme.taglist_fg_focus                          = theme.fg_focus
theme.taglist_bg_focus                          = theme.bg_focus
theme.tasklist_fg_focus                         = theme.fg_focus 
theme.tasklist_bg_focus                         = theme.bg_focus
theme.tasklist_fg_minimize                      = "#909090"
theme.menu_height                               = dpi(28) -- used as variable for various settings even though we don't have a menu
theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
theme.awesome_icon                              = theme.dir .."/icons/awesome.png"
theme.taglist_squares_sel                       = gears.surface.load_from_shape(50, dpi(2), gears.shape.rectangle, theme.fg_focus)
theme.taglist_squares_unsel                     = gears.surface.load_from_shape(50, dpi(2), gears.shape.rectangle, theme.fg_focus .. "60")
theme.layout_tile                               = theme.dir .. "/icons/tile.png"
theme.layout_tileleft                           = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom                         = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop                            = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv                              = theme.dir .. "/icons/fairv.png"
theme.layout_fairh                              = theme.dir .. "/icons/fairh.png"
theme.layout_spiral                             = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle                            = theme.dir .. "/icons/dwindle.png"
theme.layout_max                                = theme.dir .. "/icons/max.png"
theme.layout_fullscreen                         = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier                          = theme.dir .. "/icons/magnifier.png"
theme.layout_floating                           = theme.dir .. "/icons/floating.png"
theme.ocol                                      = "<span color='" .. theme.fg_normal .. "'>"
-- theme.tasklist_sticky                           = theme.ocol .. "[S]</span>"
-- theme.tasklist_ontop                            = theme.ocol .. "[T]</span>"
-- theme.tasklist_floating                         = theme.ocol .. "[F]</span>"
-- theme.tasklist_maximized_horizontal             = theme.ocol .. "[M]</span>"
-- theme.tasklist_maximized_vertical               = ""
-- disables above prepending of window type when set to true
-- theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true

--notifications
naughty.config.defaults.border_width            = dpi(3)
naughty.config.defaults.margin                  = dpi(20)
theme.notification_font                         = "Mono 9"
theme.notification_bg                           = "#333333"
theme.notification_fg                           = "#FFFFFF"
theme.notification_border_color                 = theme.fg_focus
theme.notification_max_width                    = 800

return theme
