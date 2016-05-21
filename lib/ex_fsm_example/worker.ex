require Logger
defmodule ExFsmExample.Worker do
  @behaviour :gen_fsm
  # @type state_name :: atom
  # @type state_data :: term
  # @type next_state_name :: atom
  # @type new_state_data :: term
  # @type reason :: term
  # @type reply :: term

  def start_link() do
    # start_link(FsmName, Module, Args, Options) -> Result
    :gen_fsm.start_link({:local, __MODULE__}, __MODULE__, [], [])
  end

  def init(_args) do
    state = %{socket: :undefined, name: :undefined}
    {:ok, :on, state}
  end

  # @spec handle_event(event :: term, state_name, state_data) ::
  #   {:next_state, next_state_name, new_state_data} |
  #   {:next_state, next_state_name, new_state_data, timeout} |
  #   {:next_state, next_state_name, new_state_data, :hibernate} |
  #   {:stop, reason, new_state_data} when new_state_data: term
  def handle_event(event, state_name, state_data) do
    {:next_state, state_name, state_data}
  end

  # @spec handle_sync_event(event :: term, from :: {pid, tag :: term}, state_name, state_data) ::
  #   {:reply, reply, next_state_name, new_state_data} |
  #   {:reply, reply, next_state_name, new_state_data, timeout} |
  #   {:reply, reply, next_state_name, new_state_data, :hibernate} |
  #   {:next_state, next_state_name, new_state_data} |
  #   {:next_state, next_state_name, new_state_data, timeout} |
  #   {:next_state, next_state_name, new_state_data, :hibernate} |
  #   {:stop, reason, reply, new_state_data} |
  #   {:stop, reason, new_state_data} when new_state_data: term
  def handle_sync_event(event, from, state_name, state_data) do
    {:next_state, state_name, state_data}
  end

  # @spec handle_info(info :: term, state_name, state_data) ::
  #   {:next_state, next_state_name, new_state_data} |
  #   {:next_state, next_state_name, new_state_data, timeout} |
  #   {:next_state, next_state_name, new_state_data, :hibernate} |
  #   {:stop, reason, new_state_data} when new_state_data: term
  def handle_info(info, state_name, state_data) do
    {:next_state, state_name, state_data}
  end

  # @spec terminate(reason, state_name, state_data) ::
    # term when reason: :normal | :shutdown | {:shutdown, term} | term
  def terminate(reason, state_name, state_data) do
    nil
  end

  @doc """
  In the case of an upgrade, OldVsn is Vsn, and in the case of a downgrade,
  OldVsn is {down,Vsn}. Vsn is defined by the vsn attribute(s) of the old version
  of the callback module Module. If no such attribute is defined, the version is
  the checksum of the BEAM file.
  """
  def code_change(old_vsn, state_name, state_data, extra) do
    Logger.debug "old vsn = #{inspect old_vsn}, state_name = #{inspect state_name}, state_data = #{inspect state_data}, extra = #{inspect extra}"
    new_state_data = case old_vsn do
      {:down, vsn_no} ->
         Map.delete(state_data, :name)
      _ ->
        Map.put_new(state_data, :name, :undefined)
    end
    Logger.debug "old vsn = #{inspect old_vsn}, state_name = #{inspect state_name}, new_state_data = #{inspect new_state_data}, extra = #{inspect extra}"
    {:ok, state_name, new_state_data}
  end
end
