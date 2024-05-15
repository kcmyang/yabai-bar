# yabai-bar

## About

A simple menu bar spaces indicator for the yabai window manager, written for Hammerspoon.

## Installation

Compatibility:
- yabai
  - Tested on v4.0.0^.
  - Tested on v5.0.0^.
  - Tested on v6.0.0^.
  - Tested on v7.0.0^.
- macOS
  - Tested on Monterery (macOS 12).
  - Tested on Sonoma (macOS 14).
  - Tested on Intel and Apple Silicon.

Prerequisites:
- Install and configure [yabai](https://github.com/koekeishiya/yabai).
- Install and configure [Hammerspoon](https://github.com/Hammerspoon/hammerspoon).

Installation:
- Clone this repo.
- Create `~/.hammerspoon/init.lua` if you have not already.

  ```sh
  touch ~/.hammerspoon/init.lua
  ```
- Copy `yabai-bar/yabai-bar.lua` to `~/.hammerspoon/`.

  ```sh
  cp yabai-bar/yabai-bar.lua ~/.hammerspoon/
  ```
- Configure your `init.lua` to create a new YabaiBar.
  After creation, you may choose to update the bar manually on HammerSpoon startup.
  A simple example is given below.

  ```lua
  -- init.lua
  YabaiBar = require("yabai-bar"):new{"/your/yabai/executable"}
  YabaiBar:update()
  ```

  - For more information on the constructor signature, see the documentation in
    [`yabai-bar.lua`](yabai-bar.lua).
    **In particular, Apple Silicon users will likely want to provide a specific
    directory in which to install the HammerSpoon CLI tool.**
    Bar colours can also be customized here.
- Configure your `yabairc` or `.yabairc` file to update the YabaiBar object appropriately.
  Because of how yabai's signals work, you will need multiple signals to catch all possible events.

  ```sh
  # yabairc

  # ...

  # for when a new space is made visible
  yabai -m signal --add event=space_changed action="hs -c 'YabaiBar:update()'"
  # for when the current display changes
  yabai -m signal --add event=display_changed action="hs -c 'YabaiBar:update()'"
  # display_changed does not trigger when the display changes
  # but the front-most application stays the same
  yabai -m signal --add event=application_front_switched action="hs -c 'YabaiBar:update()'"
  ```

## Usage

Under default colours, the currently focused space will appear in green.
Other visible spaces (i.e. on other desktops) will appear in yellow.
Spaces that are not visible but have visible windows will appear in light grey.
Any other spaces will appear in dark grey.

Unfortunately, not all programs play nicely with yabai and as such may not be "seen" by yabai.
As a result, dark grey spaces may still have windows there.

If you refresh yabai, you may have to revisit your spaces to make sure yabai acknowledges them and
can pass the information along to YabaiBar.

## Screenshots

![screenshot](screenshot.png "Screenshot")

## Todo
- Package this extension as a proper Hammerspoon Spoon
