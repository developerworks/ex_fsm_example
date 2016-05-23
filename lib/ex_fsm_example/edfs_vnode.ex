require Logger
defmodule ExFsmExample.EdfsVnode do
  @moduledoc """
  https://github.com/search?utf8=%E2%9C%93&q=gen_fsm+ranch_protocol+enter_loop&type=Code&ref=searchresults
  https://github.com/wot123/wot123.github.io/blob/e21a2bed506cdfad672813b05252ce42d25e5210/_posts/2015-05-12-using-ranch-to-accept-connections.markdown
  https://github.com/arianvp/venus/blob/727ede0f660bd507f2465dde139dbf225d6060fc/apps/game_server_old/lib/protocol.ex
  """
  @behaviour :ranch_protocol
  @behaviour :gen_fsm

  def start_link(ref, socket, transport, opts) do
    :proc_lib.start_link(__MODULE__, :init, [ref, socket, transport, opts], [])
  end

  def init(ref, socket, transport, opts \\ []) do
    :ok = :proc_lib.init_ack({:ok, self()})
    # Perform any required state initialization here.
    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [{:active, true}])
    # initialization state
    init_state = %{
      socket: socket,
      transport: transport,
      chunks: [],
      packet_type: 0,
      pack_len: 0,
      decrypto_state: []
    }
    # Enter loop of gen_fsm
    :gen_fsm.enter_loop(__MODULE__, [], :handshake, init_state)
  end

  def handshake(event, state_data) do
    {:next_state, :authenticate, state_data}
  end

  def authenticate(event, state_data) do
    state_data.decrypto_state |> case do
      {:ok, _} ->
        {:next_state, :authenticate_success, state_data}
      {:error, reason} ->
        {:next_state, :authenticate_failed, state_data}
    end
  end

  def authenticate_success(event, state_data) do
    {:next_state, :login, state_data}
  end

  def authenticate_failed(event, state_data) do
    {:next_state, :disconnect, state_data}
  end

  def handle_info({:tcp, _socket, data},%{
    socket: socket,
    transport: transport,
    packet_type: packet_type,
    pack_len: pack_len,
    decrypto_state: decrypto_state
  } = state) do
    :ok = transport.setopts(socket, [{:active, :once}])
    case packet_type do
      0 ->
        Logger.info "packet type 0"
        {:noreply, state}
      1 ->
        Logger.info "packet type 1"
        {:noreply, state}
      2 ->
        Logger.info "packet type2"
        {:noreply, state}
    end

  end

  def handle_event(event, state_name, state_data) do
    next_state_name = state_name
    new_state_data = state_data
    {:next_state, next_state_name, new_state_data}
  end

  def handle_sync_event(event, from, state_name, state_data) do
    next_state_name = state_name
    new_state_data = state_data
    reply = %{}
    {:reply, reply, next_state_name, new_state_data}
  end

end
