local function installCLI(ipcPath)
    local status = hs.ipc.cliStatus(ipcPath)

    if status == "broken" then
        hs.logger.new("yabai-bar"):e("Given ipcPath has an existing broken installation, please debug")
        return
    end

    if status then
        return
    end

    status = hs.ipc.cliInstall(ipcPath)

    if status == "broken" then
        hs.logger.new("yabai-bar"):e("Given ipcPath resulted in a broken installation, please debug")
        return
    end

    if not status then
        hs.logger.new("yabai-bar"):e("Failed to install hs.ipc CLI, please debug")
    end
end

local YabaiBar = {}

-- Constructor.
--
--   YabaiBar:new{
--      exec = string,
--      [ipcPath = string,]
--      [showEmptySpaces = boolean,]
--      [focusedColor = table,]
--      [visibleColor = table,]
--      [hasWindowsColor = table,]
--      [noWindowsColor = table,]
--   }
--
-- This constructor should be called using a single table argument.
-- All optional parameters should be passed by name.
-- See https://www.hammerspoon.org/docs/hs.drawing.color.html for HammerSpoon color formats.
--
-- Parameters:
--   exec - The absolute path of the yabai executable to use (usually, output of `which yabai`).
--   ipcPath - The absolute path of the directory in which to install the `hs` CLI tool.
--             Defaults to "/usr/local".  Should be a directory which the login user can write to.
--             For Intel Macs, the default should work.  On Apple Silicon, the login user does not
--             own /usr/local; if using yabai through homebrew, "/opt/homebrew" should work, but
--             creating a directory in $HOME or using $HOME/.hammerspoon is also fine.
--             The directories ipcPath/bin and ipcPath/share/man/man1 should already exist.
--             See https://www.hammerspoon.org/docs/hs.ipc.html#cliInstall for details.
--   showEmptySpaces - Whether to display indicators for empty, non-visible spaces.
--                     Defaults to true.
--   focusedColor - HammerSpoon color to use for the currently focused space.
--                  Defaults to hs.drawing.color.hammerspoon.osx_green.
--   visibleColor - HammerSpoon color to use for any visible but unfocused space.
--                  Defaults to hs.drawing.color.hammerspoon.osx_yellow.
--   hasWindowsColor - HammerSpoon color to use for any non-visible space with
--                     windows.  Defaults to {hex = "#ddd"}.
--   noWindowsColor - HammerSpoon color to use for any non-visible space without
--                    windows.  Defaults to {hex = "#666"}.
function YabaiBar:new(params)
    setmetatable(params, { __index = {
        ipcPath = "/usr/local",
        showEmptySpaces = true,
        focusedColor = hs.drawing.color.hammerspoon.osx_green,
        visibleColor = hs.drawing.color.hammerspoon.osx_yellow,
        hasWindowsColor = {hex = "#ddd"},
        noWindowsColor = {hex = "#666"},
    }})

    local exec = params[1] or params.exec
    local ipcPath = params.ipcPath
    local showEmptySpaces = params.showEmptySpaces
    local focusedColor = params.focusedColor
    local visibleColor = params.visibleColor
    local hasWindowsColor = params.hasWindowsColor
    local noWindowsColor = params.noWindowsColor

    installCLI(ipcPath)

    local yabaiBar = {
        bar = hs.menubar.new(),
        exec = exec,
        spaces = {},
        -- https://www.reddit.com/r/lua/comments/b2fekt/function_with_optional_boolean_parameter/eisq0y3/
        showEmptySpaces = showEmptySpaces ~= false,
        focusedStyle = {
            font = hs.styledtext.defaultFonts.menuBar,
            color = focusedColor
        },
        visibleStyle = {
            font = hs.styledtext.defaultFonts.menuBar,
            color = visibleColor
        },
        hasWindowsStyle = {
            font = hs.styledtext.defaultFonts.menuBar,
            color = hasWindowsColor
        },
        noWindowsStyle = {
            font = hs.styledtext.defaultFonts.menuBar,
            color = noWindowsColor
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
        local styledNums = {}

        for i = 1, #spaces do
            if spaces[i]["has-focus"] then
                -- Focused
                table.insert(styledNums, hs.styledtext.new(i, self.focusedStyle))
            elseif spaces[i]["is-visible"] then
                -- Not focused, but visible
                table.insert(styledNums, hs.styledtext.new(i, self.visibleStyle))
            elseif spaces[i]["first-window"] ~= 0 then
                -- Not visible, but with windows showing
                table.insert(styledNums, hs.styledtext.new(i, self.hasWindowsStyle))
            elseif self.showEmptySpaces then
                -- No windows showing
                table.insert(styledNums, hs.styledtext.new(i, self.noWindowsStyle))
            end
        end

        -- Text to display, as a hs.styledtext item
        local disp = styledNums[1]

        for i = 2, #styledNums do
            disp = disp .. self.separator .. styledNums[i]
        end

        self.bar:setTitle(disp)
    end, {"-m", "query", "--spaces"}):start()
end

return YabaiBar
