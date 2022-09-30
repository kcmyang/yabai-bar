if not hs.ipc.cliStatus() then
    if not hs.ipc.cliInstall() then
        hs.ipc.cliUninstall()
        if not hs.ipc.cliInstall() then
            hs.logger.new("yabai-bar"):e("Error installing `hs.ipc` :(")
        end
    end

end

local YabaiBar = {}

-- Constructor.
-- Params:
--   exec - the absolute path of the yabai executable to use
function YabaiBar:new(exec)
    local yabaiBar = {
        bar = hs.menubar.new(),
        exec = exec,
        spaces = {},
        showAll = true,
        focusedStyle = {
            font = hs.styledtext.defaultFonts.menuBar,
            color = hs.drawing.color.hammerspoon.osx_green
        },
        visibleStyle = {
            font = hs.styledtext.defaultFonts.menuBar,
            color = hs.drawing.color.hammerspoon.osx_yellow
        },
        hasWindowsStyle = {
            font = hs.styledtext.defaultFonts.menuBar,
            color = {hex = "#ddd"}
        },
        noWindowsStyle = {
            font = hs.styledtext.defaultFonts.menuBar,
            color = {hex = "#666"}
        },
        separator = hs.styledtext.new("  ", {
            font = hs.styledtext.defaultFonts.menuBar
        }) -- two spaces
    }

    self.__index = self

    return setmetatable(yabaiBar, self)
end

-- Updates the bar by querying yabai.
function YabaiBar:update()
    hs.task.new(self.exec, function(exitCode, stdOut, _)
        if exitCode ~= 0 then return end

        local spaces = hs.json.decode(stdOut)

        if #spaces == 0 then return end

        -- List of space numbers as hs.styledtext items
        local nums = {}

        for i = 1, #spaces do
            if spaces[i]["has-focus"] then
                -- Focused
                nums[i] = hs.styledtext.new(i, self.focusedStyle)
            elseif spaces[i]["is-visible"] then
                -- Not focused, but visible
                nums[i] = hs.styledtext.new(i, self.visibleStyle)
            elseif spaces[i]["first-window"] ~= 0 then
                -- Not visible, but with windows showing
                nums[i] = hs.styledtext.new(i, self.hasWindowsStyle)
            else
                -- No windows showing
                nums[i] = hs.styledtext.new(i, self.noWindowsStyle)
            end
        end

        -- Text to display, as a hs.styledtext item
        local disp = nums[1]

        for i = 2, #nums do disp = disp .. self.separator .. nums[i] end

        self.bar:setTitle(disp)
    end, {"-m", "query", "--spaces"}):start()
end

return YabaiBar
