defmodule Fw.Adapters.Gpio do
  @moduledoc """
  Specification for a production GPIO adapter.
  """

  alias Circuits.GPIO

  require Logger

  # Need a behaviour to define the interface
  # @behaviour Fw.Adapters.GpioBehaviour

  def open(pin, options), do: GPIO.open(pin, options)

  def read(gpio), do: GPIO.read(gpio)

  def write(gpio, value), do: GPIO.write(gpio, value)

  def close(gpio), do: GPIO.close(gpio)
end
