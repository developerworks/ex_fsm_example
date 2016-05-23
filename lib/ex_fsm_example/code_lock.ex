require Logger
defmodule ExFsmExample.CodeLock do
  @moduledoc """
  一个经典的密码锁状态机.
  应用场景:
  1. 比如出入办公室的自动门, 输入密码门打开, 10秒钟后自动关闭
  """

  @doc """
  用一个密码初始化这个状态机, 反转密码的顺序
  """
  def start_link(password) do
    Logger.debug "门禁的密码为: #{inspect password}"
    :gen_fsm.start_link({:local, __MODULE__}, __MODULE__, Enum.reverse(password), [])
  end

  def button(digit) do
    Logger.debug "您输入了 #{digit}"
    :gen_fsm.send_event(__MODULE__, {:button, digit})
  end

  @doc """
  初始化状态包含一个字符输入队列, 和一个密码作为初始状态
  """
  def init(password) do
    Logger.debug "密码的逆序值为: #{inspect password}"
    {:ok, :locked, {[], password}}
  end

  @doc """
  当外部调用button/1函数输入数字的时候, 执行这个状态函数
  """
  def locked({:button, digit}, {sofar, password}) do
    now = [digit | sofar]
    Logger.debug "Now: #{inspect now}, password #{inspect password}"
    case [digit | sofar] do
      ^password ->
        # do_unlock()
        Logger.debug "已打开, 3秒后自动关闭"
        {:next_state, :open, {[], password}, 3000}
      incomplete when length(incomplete) < length(password) ->
        Logger.debug "#{inspect incomplete}"
        {:next_state, :locked, {incomplete, password}}
      _wrong ->
        Logger.debug "密码错误"
        {:next_state, :locked, {[], password}}
    end
  end

  def open(:timeout, state) do
    # do_lock()
    Logger.debug "超时, 自动关闭"
    {:next_state, :locked, state}
  end
end
