defmodule Fw.Adapters.Spi do
  @moduledoc """
  Specification for an SPI adapter.

  Uses Circuits.SPI library.
  """

  alias Circuits.SPI

  # I shall abide by the adapter rules
  @behaviour Fw.Adapters.SpiBehaviour

  def open(device, options), do: SPI.open(device, options)

  def transfer(ref, data), do: SPI.transfer(ref, data)
end
