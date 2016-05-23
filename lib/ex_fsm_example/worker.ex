require Logger
defmodule ExFsmExample.Worker do
  @moduledoc """
  https://github.com/rpip/eDFS/blob/8d927d865fa0a8327a25c8fb023ded272b6739bf/apps/edfs/src/edfs_vnode.erl
  """

  @behaviour :gen_fsm
  # @type state_name :: atom
  # @type state_data :: term
  # @type next_state_name :: atom
  # @type new_state_data :: term
  # @type reason :: term
  # @type reply :: term

  def start_link() do
    Logger.debug "restart fsm process..."
    # start_link(FsmName, Module, Args, Options) -> Result

    {:ok, pid} = :gen_fsm.start_link({:local, __MODULE__}, __MODULE__, [], [])
    Logger.debug "new process pid is #{inspect pid}"
    # registered_name = :erlang.whereis(pid)
    # Logger.debug "new process registered name is #{inspect registered_name}"
    {:ok, pid}
  end

  def init(_args) do
    init_state = :state_1
    state = %{
      socket: :undefined,
      name: :undefined,
      current_state: init_state
    }
    Logger.debug "状态机初始状态 #{inspect state}"
    {:ok, init_state, state}
  end

  def test_send do
    :gen_fsm.send_all_state_event(__MODULE__, :test_send)
  end

  @doc """
  Go to state_1
  """
  def state_1 do
    Logger.debug "发生事件 state_1"
    :gen_fsm.send_event(__MODULE__, :state_1)
  end
  def state_1(event, state_data) do
    Logger.debug "event #{inspect event}状态1, 当前状态数据 #{inspect state_data}"
    # %{ state_data | current_state: state_2}
    {:next_state, :state_2, state_data}
  end

  @doc """
  Go to state_2
  """
  def state_2 do
    :gen_fsm.send_event(__MODULE__, :state_2)
  end
  def state_2(event, state_data) do
    Logger.debug "#{inspect event} 状态2, 当前状态数据 #{inspect state_data}"
    {:next_state, :state_3, state_data}
  end
  def state_2(event, from, state_data) do
    Logger.debug "sync event form #{inspect from}, state data: #{inspect state_data}"
    {:reply, :state_2, :state_3, state_data}
  end

  @doc """
  Go to state_3
  """
  def state_3 do
    :gen_fsm.send_event(__MODULE__, :state_3)
  end
  def state_3(event, state_data) do
    Logger.debug "状态3, 当前状态数据 #{inspect state_data}"
    {:next_state, :state_1, state_data}
  end

  # @spec handle_event(event :: term, state_name, state_data) ::
  #   {:next_state, next_state_name, new_state_data} |
  #   {:next_state, next_state_name, new_state_data, timeout} |
  #   {:next_state, next_state_name, new_state_data, :hibernate} |
  #   {:stop, reason, new_state_data} when new_state_data: term
  def handle_event(event, state_name, state_data) do
    Logger.debug "Receved event: #{inspect event}, State name: #{inspect state_name}, State data: #{inspect state_data}"
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
    Logger.debug "SYNC:Receved event: #{inspect event}, State name: #{inspect state_name}, State data: #{inspect state_data}"
    {:next_state, state_name, state_data}
  end

  # @spec handle_info(info :: term, state_name, state_data) ::
  #   {:next_state, next_state_name, new_state_data} |
  #   {:next_state, next_state_name, new_state_data, timeout} |
  #   {:next_state, next_state_name, new_state_data, :hibernate} |
  #   {:stop, reason, new_state_data} when new_state_data: term
  def handle_info(info, state_name, state_data) do
    Logger.debug "Receved info: #{inspect info}, State name: #{inspect state_name}, State data: #{inspect state_data}"

    {:next_state, state_name, state_data}
  end

  # @spec terminate(reason, state_name, state_data) ::
    # term when reason: :normal | :shutdown | {:shutdown, term} | term
  def terminate(reason, state_name, state_data) do
    Logger.debug "fsm exit with reason #{inspect reason}, state name #{state_name}, state data #{state_data}"
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
      {:down, _vsn_no} ->
        Map.delete(state_data, :name)
      _ ->
        Map.put_new(state_data, :name, :undefined)
    end
    Logger.debug "old vsn = #{inspect old_vsn}, state_name = #{inspect state_name}, new_state_data = #{inspect new_state_data}, extra = #{inspect extra}"
    {:ok, state_name, new_state_data}
  end
end
