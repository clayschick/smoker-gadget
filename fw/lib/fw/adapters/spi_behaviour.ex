defmodule Fw.Adapters.SpiBehaviour do

  @callback open(device :: String.t(), options :: charlist()) :: {:ok, reference()}

  @callback transfer(ref :: reference(), data :: binary) :: {:ok, binary()}
end