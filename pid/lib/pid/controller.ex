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

    accumulation_of_error = state.accumulation_of_error + error * time_delta

    integral = state.i_term + state.ki * error

    derivative_of_input = (input - state.last_input) / time_delta

    # output = state.kp * error + state.ki * accumulation_of_error - state.kd * derivative_of_input
    output = state.kp * error + integral - state.kd * derivative_of_input

    :ok =
      Pid.Agent.update(
        accumulation_of_error: accumulation_of_error,
        last_input: input,
        last_output: output,
        last_time: now,
        i_term: integral
      )

    output
  end

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
    Fw.Temperature.read()
    |> evaluate()
    |> Fw.Fan.adjust()

    # Again with these timers in a loop!
    Process.sleep(500)

    state = Pid.Agent.get_state()

    eval_loop(%{auto: state.auto})
  end

  #################################################################
  # Everything below is my experiment to run things in a stream
  # versus a recursive loop like above.
  #################################################################

  def eval_stream() do
    # This will allow the caller would use Enum.reduce to initiate the "loop"

    # Can I use this without depending on the Pid.Agent.State?
    # - the state is used to see if we need to stop the loop
    # -- the caller can now stop the loop by using Enum.take_while and checking it's own state
    # - the state is used to allow real-time adjustment of tuning values and the setpoint
    # - how can I "inject" these values into the stream from the caller - it is the UI that knows about and handles these changes
    # I think I would have to stop the stream and restart it with updated values

    initial_state = %{
      accumulation_of_error: 0,
      last_time: DateTime.utc_now() |> DateTime.to_unix(:millisecond),
      last_integral: 0,
      last_input: read(),
      last_output: 0
    }

    # Start the sequence by checking a state external to the controller that has the
    # tuning setting and setpoint so that these can be changed on-the-fly
    Stream.repeatedly(get_external_state())
    |> Stream.map(fn ext_state -> {read(), ext_state} end)
    |> Stream.scan(initial_state, fn {input, ext_state}, acc_state ->
      evaluate(input, ext_state, acc_state)
    end)
    |> Stream.map()
  end

  def evaluate(input, ext_state, acc_state) do
    now = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    time_delta = now - acc_state.last_time

    error = ext_state.setpoint - input

    accumulation_of_error = acc_state.accumulation_of_error + error * time_delta

    integral = acc_state.last_integral + ext_state.ki * error

    derivative_of_input = (input - acc_state.last_input) / time_delta

    output = ext_state.kp * error + integral - ext_state.kd * derivative_of_input

    %{
      acc_state
      | accumulation_of_error: accumulation_of_error,
        last_time: now,
        last_integral: integral,
        last_input: input,
        last_output: output
    }
  end

  # def run() do
  #   # This seems like a lot of atom to create which may
  #   # cause memory to grow since they are not garbage collected
  #   with {:read, {:ok, input_stream}} <- {:read, read()},
  #        {:evaluate, {:ok, output}} <- {:evaluate, evaluate(input_stream)},
  #        {:adjust, {:ok, _}} <- {:adjust, adjust(output)} do
  #     {:ok, %{input: input, output: output}}
  #   else
  #     # Can pattern match on the error to be more specific
  #     {:read, _} -> {:error, "Error while reading input"}
  #     {:evaluate, _} -> {:error, "Error while evaluating"}
  #     {:adjust, _} -> {:error, "Error while adjusting"}
  #   end
  # end

  #########################################################################
  # Everything below is my experiment to run things in a `with` statement
  #########################################################################

  # def run() do
  #   # This seems like a lot of atom to create which may
  #   # cause memory to grow since they are not garbage collected
  #   with {:read, {:ok, input}} <- {:read, read()},
  #        {:evaluate, {:ok, output}} <- {:evaluate, evaluate(input)},
  #        {:adjust, {:ok, _}} <- {:adjust, adjust(output)} do
  #     {:ok, %{input: input, output: output}}
  #   else
  #     # Can pattern match on the error to be more specific
  #     {:read, _} -> {:error, "Error while reading input"}
  #     {:evaluate, _} -> {:error, "Error while evaluating"}
  #     {:adjust, _} -> {:error, "Error while adjusting"}
  #   end
  # end

  @doc """
  Use these functions to handle adapter config stuff and other things
  specific to reading and adjusting the side-effecty things
  """
  def read(), do: Fw.Temperature.read()

  def adjust(), do: Fw.Fan.adjust()

  def get_external_state(), do: Pid.Agent.get_state()
end
