defmodule GeoLocation.Importer do
  alias GeoLocation.ImportFlow
  use GenServer

  # 30 minutes
  @timeout 1000 * 60 * 30
  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{ref: nil, caller: nil}, opts)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_flow(data_stream, caller) do
    GenServer.call(__MODULE__, {:start_flow, data_stream, caller})
  end

  # the flow is already running
  def handle_call({:start_flow, _data_stream}, _from, %{ref: ref} = state)
      when is_reference(ref) do
    {:reply, :ok, state}
  end

  # start a new flow
  def handle_call({:start_flow, data_stream, caller}, _from, %{ref: nil} = state) do
    task =
      Task.Supervisor.async_nolink(
        GeoLocation.TaskSupervisor,
        fn ->
          ImportFlow.import(data_stream)
        end,
        shutdown: @timeout
      )

    {:reply, :ok, %{state | ref: task.ref, caller: caller}}
  end

  def handle_info({ref, result}, %{ref: ref} = state) when is_reference(ref) do
    send(state.caller, {:ok, result})
    # notify caller with the result
    Process.demonitor(ref, [:flush])
    {:noreply, %{state | ref: nil, caller: nil}}
  end

  def handle_info({:DOWN, _, _, _, _}, %{ref: ref} = state) when is_reference(ref) do
    send(state.caller, :error)
    {:noreply, %{state | ref: nil, caller: nil}}
  end
end
