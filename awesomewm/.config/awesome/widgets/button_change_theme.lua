local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local noti = require("util.noti")
local widget = require("util.widgets")
local helpers = require("helpers")
local table = require('gears.table')
local icons = require("icons.default")
local font = require("util.font")
local app = require("util.app")
local btext = require("util.mat-button")
local ufont = require("utils.font")
local iicon = require("config.icons")
local button = require("utils.button")

-- beautiful vars
local fg = beautiful.widget_change_theme_fg or M.x.on_background
local bg = beautiful.widget_change_theme_bg or M.x.background
local l = beautiful.widget_change_theme_layout or 'horizontal'
local space = beautiful.widget_spacing or dpi(1)

-- add a little margin to avoid the popup pasted on the wibar
local padding = beautiful.widget_popup_padding or 1

-- button creation
local w = button({
  fg_icon = M.x.on_background,
  icon = ufont.icon(iicon.widget.change_theme),
  layout = "horizontal"
})

local rld = button({
  fg_icon = M.x.on_background,
  icon = ufont.icon(iicon.widget.reload),
  command = awesome.restart,
  layout = "horizontal"
})

local function make_element(name)
  local change_script = function()
    app.start(
      "~/.config/awesome/widgets/change-theme.sh --change "..name,
      true, "miniterm"
    )
    noti.info("Theme changed, Reload awesome for switch on "..name)
  end
  local element = wibox.widget {
    widget.centered(widget.imagebox(90, icons.app[name])),
    font.button(name, M.x.on_surface, M.t.medium),
    layout = wibox.layout.fixed.vertical
  }
  local w = btext({
    command = change_script, wtext = element, overlay = "on_surface"
  })
  return w
end

local popup_anonymous = make_element("anonymous")
local popup_sci = make_element("sci")
local popup_miami = make_element("miami")
local popup_machine = make_element("machine")
local popup_morpho = make_element("morpho")
local popup_worker = make_element("worker")

local w_position -- the position of the popup depend of the wibar
w_position = widget.check_popup_position(beautiful.wibar_position)

local popup_widget = wibox.widget {
  {
    {
      {
        {
          nil,
          font.h6("Change theme", M.x.on_surface, M.t.high),
          rld,
          expand = "none",
          layout = wibox.layout.align.horizontal
        },
        forced_height = 48,
        widget = wibox.container.margin
      },
      {
        popup_anonymous,
        popup_machine,
        popup_miami,
        popup_morpho,
        popup_worker,
        popup_sci,
        forced_num_rows = 2,
        forced_num_cols = 3,
        spacing = 10,
        layout = wibox.layout.grid,
      },
      layout = wibox.layout.fixed.vertical
    },
    top = 8, bottom = 8,
    left = 24, right = 24,
    widget = wibox.container.margin
  },
  shape = helpers.rrect(20),
  bg = M.x.on_surface .. M.e.dp01,
  widget = wibox.container.background
}

local popup = awful.popup {
  widget = popup_widget,
  visible = false, -- do not show at start
  ontop = true,
  hide_on_right_click = true,
  preferred_positions = w_position,
  offset = { y = padding, x = padding }, -- no pasted on the bar
  bg = M.x.surface
}

-- attach popup to widget
popup:bind_to_widget(w)
w:buttons(table.join(
awful.button({}, 3, function()
  w.visible = false
end)
))

return w
