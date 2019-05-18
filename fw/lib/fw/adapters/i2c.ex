defmodule Fw.Adapters.I2C do
  @moduledoc """
  Specification for a production GPIO adapter.
  """

  alias Circuits.I2C

  # Need a behaviour to define the interface
  # @behaviour Fw.Adapters.I2CBehaviour

  def open(bus_name), do: I2C.open(bus_name)

  def read(ref, address, bytes_to_read, opts \\ []) do
    I2C.read(ref, address, bytes_to_read, opts)
  end

  def write(ref, address, data, opts \\ []) do
    I2C.write(ref, address, data, opts)
  end

  @doc """
  write_data will be a "register"
  """
  def write_read(ref, address, write_data, bytes_to_read, opts \\ []) do
    I2C.write_read(ref, address, write_data, bytes_to_read, opts)
  end
end
