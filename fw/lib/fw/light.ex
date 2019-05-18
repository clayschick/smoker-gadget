defmodule Fw.Light do
  @moduledoc """
  Using the Circuits.I2C library to read a value from a
  a VEML7700 light sensor.
  """

  @resolution_at_max 0.0036
  @gain_max 2
  @integration_time_max 800

  use Agent

  require Logger

  @default_adapter Fw.Adapters.I2C

  @doc """
  Use Keyword.fetch!/2 for required fields in the options list
  """
  def start_link(_option_list \\ []) do
    Agent.start_link(&connect/0, name: __MODULE__)
  end

  def connect do
    config = Application.get_env(:fw, Fw.Light, [])
    adapter = config[:i2c_adapter] || @default_adapter

    {:ok, ref} = adapter.open("i2c-1")

    # Write to the config register - 0x00
    # Turn on the sensor
    # Default integration time of 100ms (total refresh time is 600ms)
    # Set the gain to x2 (this is the max)
    # _ = adapter.write(ref, 16, <<0x00, 0x00, 0x08>>)
    # Set the gain to x0.125 (this is the min)
    # _ = adapter.write(ref, 16, <<0x00, 0x03, 0x10>>)

    # The most sensitive setting - gain of 2 and IT of 800ms
    _ = adapter.write(ref, 16, <<0x00, 0x00, 0xC8>>)

    %{ref: ref, adapter: adapter}
  end

  def read do
    %{ref: ref, adapter: adapter} = Agent.get(__MODULE__, & &1)

    # Read the white light data
    {:ok, <<light::size(16)>>} = adapter.write_read(ref, 16, <<0x05>>, 2)

    Logger.debug("Light Reading: #{light}")

    resolution = @resolution_at_max * (@integration_time_max / 800) * (@gain_max / 2)

    Logger.debug("Resolution: #{resolution}")

    lux = resolution * light

    Logger.debug("Lux: #{lux}")

    trunc(lux)
  end
end
