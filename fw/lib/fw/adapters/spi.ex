defmodule Fw.Adapters.Spi do
  @moduledoc """
  Specification for a production SPI adapter.
  """

  alias Circuits.SPI

  # I shall abide by the adapter rules
  @behaviour Fw.Adapters.SpiBehaviour

  @impl true
  def open(device, options), do: SPI.open(device, options)

  @impl true
  def transfer(ref, data), do: SPI.transfer(ref, data)
end
