defmodule ExFsmExample do
  use Application
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(ExFsmExample.Worker, []),
    ]
    opts = [strategy: :one_for_one, name: ExFsmExample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
