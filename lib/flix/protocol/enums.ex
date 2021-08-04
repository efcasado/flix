defmodule Flix.Protocol.Enums do
  use EnumType

  defenum CreateConnectionChannelError do
    value(NoError, 0)
    value(MaxPendingConnectionsReached, 1)

    default(NoError)
  end

  defenum ConnectionStatus do
    value(Disconnected, 0)
    value(Connected, 1)
    value(Ready, 2)

    default(Disconnected)
  end

  defenum DisconnectReason do
    value(Unspecified, 0)
    value(ConnectionEstablishmentFailed, 1)
    value(TimedOut, 2)
    value(BondingKeyMismatch, 3)

    default(Unspecified)
  end

  defenum RemovedReason do
    value(RemovedByThisClient, 0)
    value(ForceDisconnectedByThisClient, 1)
    value(ForceDisconnectedByOtherClient, 2)
    value(ButtonIsPrivate, 3)
    value(VerifyTimeout, 4)
    value(InternetBackendRrror, 5)
    value(InvalidData, 6)
    value(CouldNotLoadDevice, 7)
    value(DeletedByThisClient, 8)
    value(DeletedByOtherClient, 9)
    value(ButtonBelongsToOtherPartner, 10)
    value(DeletedFromButton, 11)

    default(RemovedByThisClient)
  end

  defenum ClickType do
    value(Down, 0)
    value(Up, 1)
    value(Click, 2)
    value(SingleClick, 3)
    value(DoubleClick, 4)
    value(Hold, 5)

    default(Down)
  end

  defenum BdAddrType do
    value(Public, 0)
    value(Random, 1)

    default(Public)
  end

  defenum LatencyMode do
    value(Normal, 0)
    value(Low, 1)
    value(High, 2)

    default(Normal)
  end

  defenum BluetoothControllerState do
    value(Detached, 0)
    value(Resetting, 1)
    value(Attached, 2)

    default(Detached)
  end

  defenum ScanWizardResult do
    value(Success, 0)
    value(CancelledByUser, 1)
    value(FailedTimeout, 2)
    value(ButtonIsPrivate, 3)
    value(BluetoothUnavailable, 4)
    value(InternetBackendError, 5)
    value(InvalidData, 6)
    value(ButtonBelongsToOtherPartner, 7)
    value(ButtonAlreadyConnectedToOtherDevice, 8)

    default(Success)
  end
end
