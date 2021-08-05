# Flix

[![Build Status](https://efcasado.semaphoreci.com/badges/flix/branches/master.svg?style=shields)](https://efcasado.semaphoreci.com/projects/flix) [![Hex.pm](https://img.shields.io/hexpm/v/flix.svg)](https://hex.pm/packages/flix)  [![Hexdocs.pm]()](https://hexdocs.pm/flix/0.1.0/)

An Elixir client for the [Flic](https://flic.io/) button.

### What's in the name?

The name `Flix` is the result of combining `Fli(c)`, the name of the button, and
`(e)x`, the extension used by Elixir source files.

[Flix](https://en.wikipedia.org/wiki/Flix) is also a town in the beautiful
province of Tarragona, Catalonia, Spain.


### The Flic protocol

`Flix` implements the full Flic protocol as per described in the
official fliclib-linux-hci [GitHub repository](https://github.com/50ButtonsEach/fliclib-linux-hci/blob/master/ProtocolDocumentation.md).


### Usage

Flic buttons don't connect directly to `Flix` nor the other way around. Flic buttons connect
to a `flicd` via bluetooth. `Flix` applications also connect to `flicd` but via a TCP. See
the diagram below.

```
+------------+  command(s)  +---------+               +---------------+
|            +------------->|         |               |               |
|  Flix App  |     TCP      |  flicd  |<--------------+  Flic Button  |
|            |<-------------+         |   Bluetooth   |               |
+------------+   event(s)   +---------+               +---------------+
```

You can find more information about Flic's `flicd` in its
[official page](https://github.com/50ButtonsEach/fliclib-linux-hci).

Writing a Flix application is as simple as defining a new Elixir module,
using Flix's `__using__` macro (ie. `use Flix`) and implementing Flix's
`handle_event/2` callback function.

```elixir
defmodule MyFlixApp do
  use Flix

  def handle_event(event, state) do
    new_state = do_something(event, state)
    {:ok, new_state}
  end
end
```

Below is a full example of a Flix application where a counter is initialised to `0`
and increased or decreased by one when someone does single- or double-clicks a Flic
button, respectively. The code makes the following assumptions:
- `flicd` is running and reachable on `raspberrypi.local:5551`.
- The Flic button (ie. `"80:E4:DA:78:45:1B"`) has already been paired with `flicd`.

```elixir
defmodule Flix.Examples.Counter do
  use Flix

  alias Flix.Protocol.Events.ButtonSingleOrDoubleClickOrHold
  alias Flix.Protocol.Enums.ClickType

  def start(host \\ 'raspberrypi.local', port \\ 5551) do
    {:ok, client} = Flix.start(__MODULE__, 0, host, port)
    :ok = set_up(client)
    {:ok, client}
  end

  def start_link(host \\ 'raspberrypi.local', port \\ 5551) do
    {:ok, client} = Flix.start_link(__MODULE__, 0, host, port)
    :ok = set_up(client)
    {:ok, client}
  end

  def set_up(client) do
    :ok = Flix.create_connection_channel(client, "80:E4:DA:78:45:1B", 1)
  end

  def stop(client) do
    :ok = Flix.stop(client)
  end

  def handle_event(
    %ButtonSingleOrDoubleClickOrHold{click_type: ClickType.SingleClick},
    count
  ) do
    new_count = count + 1
    IO.puts "Count = #{new_count}"
    {:ok, new_count}
  end
  def handle_event(
    %ButtonSingleOrDoubleClickOrHold{click_type: ClickType.DoubleClick},
    count
  ) do
    new_count = count - 1
    IO.puts "Count = #{new_count}"
    {:ok, new_count}
  end
  def handle_event(event, count) do
    require Logger
    Logger.debug("No handle_event/2 clause in #{__MODULE__} for #{inspect(event)}")
    {:ok, count}
  end
end
```


### Author(s)

- Enrique Fernandez `<efcasado@gmail.com>`


### Acknowledgements

I would like to thank [BlueLabs](https://www.bluelabs.eu/) for sponsoring the
development of `Flix` by creating an opportunity for me to work on this project.

This project was conceived during BlueLabs' 2nd Hackathon (22-23 July, 2021).

[![BlueLabs](images/bluelabs-logo.png?raw=true "BlueLabs")](https://www.bluelabs.eu/)


### License

> The MIT License (MIT)
>
> Copyright (c) 2021, Enrique Fernandez
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
> THE SOFTWARE.