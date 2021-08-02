# Flix

[![Build Status](https://efcasado.semaphoreci.com/badges/flix/branches/master.svg?style=shields)](https://efcasado.semaphoreci.com/projects/flix)

An Elixir client for the [Flic](https://flic.io/) button.

### What's in the name?

The name `Flix` is the result of combining `Fli(c)`, the name of the button, and
`(e)x`, the extension used by Elixir source files.

[Flix](https://en.wikipedia.org/wiki/Flix) is also a town in the beautiful
province of Tarragona, Catalonia, Spain.


### The Flic protocol

`Flix` implements the full Flic protocol as per described in the
[official fliclib-linux-hci GitHub repository](https://github.com/50ButtonsEach/fliclib-linux-hci/blob/master/ProtocolDocumentation.md).


### Usage

```elixir
defmodule Flix.Examples.Counter do
  use Flix

  alias Flix.Protocol.Events.ButtonSingleOrDoubleClickOrHold
  alias Flix.Protocol.Enums.ClickType

  def start(host \\ 'raspberrypi.local', port \\ 5551) do
    Flix.start(__MODULE__, 0, host, port)
  end

  def start_link(host \\ 'raspberrypi.local', port \\ 5551) do
    Flix.start_link(__MODULE__, 0, host, port)
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