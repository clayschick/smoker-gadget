defmodule Pid.Controller do
  @moduledoc """
  PID Controller implementation.
  """

  require Logger

  @doc """
  The controller function that evaluates an output value to be applied to
  something that will adjust the input.

  What should the sample rate be and how can I make it consistent?
  - the MAX31865 needs at least 65 milliseconds because it has a frequency
    at which it will cycle through a read or write
  """
  def evaluate(input) do
    Logger.debug("Current Input: #{input}")

    state = Pid.Agent.get_state()
    now = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    time_delta = now - state.last_time
    Logger.debug("Time Delta: #{time_delta}")

    error = state.setpoint - input
    Logger.debug("Error: #{error}")

    integral = state.i_term + (state.ki * error)
    Logger.debug("Integral: #{integral}")

    derivative_of_input = input - state.last_input
    Logger.debug("Derv Of Input: #{derivative_of_input}")

    output = (state.kp * error) + integral - state.kd * derivative_of_input

    :ok =
      Pid.Agent.update(
        last_input: input,
        last_output: output,
        last_time: now,
        i_term: integral
      )

    output
  end

  @doc """
  Use these functions to handle adapter config stuff and other things
  specific to reading and adjusting the side-effecty things
  """
  # def read, do: Fw.Temperature.read()
  def read, do: Fw.Light.read()

  # def adjust(output), do: Fw.Fan.adjust(output)
  def adjust(output), do: Fw.Led.adjust(output)

  @doc """
  With statement used as an implementation of the read/evaluate/adjust
  cycle. Returns the input and output together to be consumed by the UI.

  Need to make the timer value configurable.
  """
  def cycle do
    with {:read, input} <- {:read, read()},
         {:evaluate, output} <- {:evaluate, evaluate(input)},
         {:adjust, :ok} <- {:adjust, adjust(output)},
         _ <- :timer.sleep(1300) do
      {:ok, %{input: input, output: output}}
    else
      {:read, msg} -> {:error, "Error while reading input - #{msg}"} |> Logger.error()
      {:evaluate, msg} -> {:error, "Error while evaluating - #{msg}"} |> Logger.error()
      {:adjust, msg} -> {:error, "Error while adjusting - #{msg}"} |> Logger.error()
    end
  end

  def basic_controller(input) do
    state = Pid.Agent.get_state()
    now = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    time_delta = now - state.last_time

    error = state.setpoint - input

    accumulation_of_error = state.accumulation_of_error + (error * time_delta)

    derivative_of_error = (error - state.last_error) / time_delta

    output = (state.kp * error) + (state.ki * accumulation_of_error) + (state.kd * derivative_of_error)

    :ok =
      Pid.Agent.update(
        accumulation_of_error: accumulation_of_error,
        last_input: input,
        last_output: output,
        last_time: now,
        last_error: error
      )

    output
  end
end
