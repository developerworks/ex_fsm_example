require Logger
defmodule ExFsmExample do
  use Application
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # worker(ExFsmExample.Worker, [], [restart: :permanent]),
      worker(ExFsmExample.CodeLock, [[1,2,3,4,5,6]])
    ]
    opts = [strategy: :one_for_one, name: ExFsmExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def stop(state) do
    Logger.debug "Appcation #{__MODULE__} exit. STATUS: #{inspect state}"
  end
end
