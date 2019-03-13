defmodule Pid.Controller do
  @moduledoc """
  PID Controller
  """

  @doc """
  The controller function that evaluates an output value to be applied to
  something that will adjust the input.

  What should the sample rate be and how can I make it consistent?
  - the MAX31865 needs at least 65 milliseconds because it has a frequency
    at which it will cycle through a read or write
  """
  def evaluate(input) do
    state = Pid.Agent.get_state()
    now = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    time_delta = now - state.last_time

    error = state.setpoint - input

    # accumulation_of_error = state.accumulation_of_error + error * time_delta

    integral = state.i_term + state.ki * error

    derivative_of_input = (input - state.last_input) / time_delta

    # output = state.kp * error + state.ki * accumulation_of_error - state.kd * derivative_of_input
    output = state.kp * error + integral - state.kd * derivative_of_input

    :ok =
      Pid.Agent.update(
        # accumulation_of_error: accumulation_of_error,
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
  def read(), do: Fw.Temperature.read()

  def adjust(output), do: Fw.Fan.adjust(output)

  @doc """
  Used to start the controller's read/evaluate/adjust pipeline loop.

  Sets an initial state to be used by the functions in the pipeline.
  """
  def run() do
    now = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    current_temp = Fw.Temperature.read()

    :ok =
      Pid.Agent.update(
        last_time: now,
        last_input: current_temp
      )

    eval_loop(%{auto: true})
  end

  def eval_loop(%{auto: false}), do: :ok

  def eval_loop(%{auto: true}) do
    read()
    |> evaluate()
    |> adjust()

    # Again with these timers in a loop!
    Process.sleep(500)

    state = Pid.Agent.get_state()

    eval_loop(%{auto: state.auto})
  end


  def eval_stream() do
    now = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    current_temp = Fw.Temperature.read()

    :ok =
      Pid.Agent.update(
        last_time: now,
        last_input: current_temp
      )

    Stream.repeatedly(fn -> run_with() end)
  end

  def run_with() do
    # This seems like a lot of atoms to create which may
    # cause memory to grow since they are not garbage collected.
    # Can I use strings instead?
    with {:read, input} <- {:read, read()},
         {:evaluate, output} <- {:evaluate, evaluate(input)},
         {:adjust, :ok} <- {:adjust, adjust(output)},
         _ <- :timer.sleep(500) do
      {:ok, %{input: input, output: output}}
    else
      # Can pattern match on the error to be more specific
      {:read, msg} -> {:error, "Error while reading input - #{msg}"}
      {:evaluate, msg} -> {:error, "Error while evaluating - #{msg}"}
      {:adjust, msg} -> {:error, "Error while adjusting - #{msg}"}
    end
  end

  # def get_external_state(), do: Pid.Agent.get_state()
end
