Monitor1="HDMI-A-1"
Monitor2="DP-3"
Monitor3="eDP-1"

-- See https://wiki.hypr.land/Configuring/Monitors/

hl.monitor({output=Monitor1, mode="preferred", position="0x0", scale="1.5"})
hl.monitor({output=Monitor2, mode="preferred", position="2560x0", scale="1.5"})
hl.monitor({output=Monitor3, mode="preferred", position="5120x700", scale="1"})

-- ---@param monitor HL.Monitor
-- local arrangeMonitor = function (monitor)
--     if monitor.name == Monitor1 then
--         hl.monitor({output=Monitor1, mode="preferred", position="0x0", scale="1.5"})
--     elseif monitor.name == Monitor2 then
--         hl.monitor({output=Monitor2, mode="preferred", position="2560x0", scale="1.5"})
--     elseif monitor.name == Monitor3 then
--         hl.monitor({output=Monitor3, mode="preferred", position="5120x700", scale="1"})
--     end
-- end

-- hl.on("monitor.added", arrangeMonitor)
-- hl.on("monitor.removed", arrangeMonitor)