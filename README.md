# Flix

[![Build Status](https://efcasado.semaphoreci.com/badges/flix/branches/master.svg?style=shields)]

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
client = Flix.connect("raspberrypi.local", 55551)

:ok = Flix.subscribe(client, self())

:ok = Flix.get_info(client)
flush
%Flix.Protocol.Events.GetInfoResponse{
  bluetooth_controller_state: Flix.Protocol.Enums.BluetoothControllerState.Attached,
  bluetooth_device_address: "B8:27:EB:3A:A0:8F",
  bluetooth_device_address_type: Flix.Protocol.Enums.BdAddrType.Public,
  max_concurrently_connected_buttons: 65535,
  max_pending_connections: 128,
  no_space_for_new_connections: false,
  number_pending_connections: 0,
  number_verified_buttons: 2,
  verified_buttons: ["80:E4:DA:71:EE:BE", "80:E4:DA:78:45:1B"]
}

:ok = Flix.get_button_info(client, "80:E4:DA:71:EE:BE")
flush
%Flix.Protocol.Events.GetButtonInfoResponse{
  bt_addr: "80:E4:DA:71:EE:BE",
  color: "black",
  color_length: 5,
  firmware_version: 0,
  flic_version: 1,
  serial_number: "AF25-B03504",
  serial_number_length: 11,
  uuid: "12891B37DCDD00D9DD2A543577782AD"
}

:ok = Flix.create_connection_channel(client, "80:E4:DA:71:EE:BE", 1)
flush

flush
%Flix.Protocol.Events.ConnectionStatusChanged{
  conn_id: 1,
  conn_status: Flix.Protocol.Enums.ConnectionStatus.Connected,
  disconnect_reason: Flix.Protocol.Enums.DisconnectReason.Unspecified
}
%Flix.Protocol.Events.ButtonUpOrDown{
  click_type: Flix.Protocol.Enums.ClickType.Down,
  conn_id: 1,
  time_diff: 0,
  was_queued: 1
}
%Flix.Protocol.Events.ConnectionStatusChanged{
  conn_id: 1,
  conn_status: Flix.Protocol.Enums.ConnectionStatus.Disconnected,
  disconnect_reason: Flix.Protocol.Enums.DisconnectReason.Unspecified
}
%Flix.Protocol.Events.ConnectionStatusChanged{
  conn_id: 1,
  conn_status: Flix.Protocol.Enums.ConnectionStatus.Connected,
  disconnect_reason: Flix.Protocol.Enums.DisconnectReason.Unspecified
}
%Flix.Protocol.Events.ButtonClickOrHold{
  click_type: Flix.Protocol.Enums.ClickType.Click,
  conn_id: 1,
  time_diff: 0,
  was_queued: 1
}
%Flix.Protocol.Events.ConnectionStatusChanged{
  conn_id: 1,
  conn_status: Flix.Protocol.Enums.ConnectionStatus.Disconnected,
  disconnect_reason: Flix.Protocol.Enums.DisconnectReason.Unspecified
}
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