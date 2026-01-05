<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Terminal Output During TUI Sessions

## The Problem

Writing to stdout or stderr during a TUI session **corrupts the display**.

When your application is running inside `RatatuiRuby.run`, the terminal is in "raw mode" and RatatuiRuby has taken control of the display buffer. Any output via `puts`, `warn`, `p`, `print`, or direct writes to `STDOUT`/`STDERR` will:

1. **Corrupt the screen layout** - Characters appear in random positions
2. **Mix with TUI output** - Text interleaves with your widgets unpredictably
3. **Trigger escape sequence errors** - Partial ANSI codes can break rendering

## Why This Happens

In raw mode:
- The terminal doesn't process newlines or carriage returns normally
- Output bypasses the TUI's controlled buffer
- Cursor position is undefined from the TUI's perspective

## Safe Patterns

### Defer output until after the TUI exits

```ruby
messages = []

RatatuiRuby.run do |tui|
  # Collect messages instead of printing them
  messages << "Something happened"
  
  # ... TUI logic ...
end

# Now safe to print
messages.each { |msg| puts msg }
```

### Use debug logging to a file

```ruby
DEBUG_LOG = File.open("/tmp/my_app_debug.log", "a")

RatatuiRuby.run do |tui|
  DEBUG_LOG.puts "Debug: something happened"
  DEBUG_LOG.flush
  
  # ... TUI logic ...
end
```

### Display messages in the TUI itself

```ruby
RatatuiRuby.run do |tui|
  @status_message = "Something happened"
  
  tui.draw do |frame|
    # Show status in the UI
    frame.render_widget(
      tui.paragraph(text: @status_message),
      status_area
    )
  end
end
```

## Library Behavior

RatatuiRuby automatically defers its own warnings (like experimental feature notices) during TUI sessions. They are queued and printed after `restore_terminal` is called.

You don't need to do anything special for library warnings—they're handled automatically.
