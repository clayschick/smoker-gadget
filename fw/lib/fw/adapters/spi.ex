defmodule Fw.Adapters.Spi do
  @moduledoc false

  alias Circuits.SPI

  @behaviour Fw.Adapters.SpiBehaviour

  def open(device, options), do: SPI.open(device, options)

  def transfer(ref, data), do: SPI.transfer(ref, data)
end
