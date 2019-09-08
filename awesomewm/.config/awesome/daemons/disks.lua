local aspawn = require("awful.spawn")
local awidget = require("awful.widget")

-- Add files system you want to track, the line bellow match with:
-- /home/yagdra, /opt/musics and /opt/torrents for me :)
local myfs = { "yagdra", "musics", "torrents" } 

local fs_info = {}

local function sformat_in_giga(value)
  return string.format("%.1f", value/1024^2)
end

local function disks_info()
  aspawn.with_line_callback('sh -c "df -kP"', { stdout = function(line)
    local s, u, a, p, m = line:match("^.-%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%%%s+([%p%w]+)")
    -- check if it's match with myfs and add to the table
    for _, fs in pairs(myfs) do
      if m ~= nil and m:match(fs) then
        if u and m then -- Handle 1st line and broken regexp
          fs_info[_] = {}
          fs_info[_]["size"] = sformat_in_giga(s)
          fs_info[_]["used"] = sformat_in_giga(u)
          fs_info[_]["available"] = sformat_in_giga(a)
          fs_info[_]["used_percent"] = p
          fs_info[_]["mountpoint"] = m
        end
      end
    end
  end})
  awesome.emit_signal("daemon::disks", fs_info)
end

awidget.watch('sh -c ":"', 50, function(widget, stdout)
  disks_info()
end)