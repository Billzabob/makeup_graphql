defmodule MakeupGraphql.Application do
  @moduledoc false
  use Application

  alias Makeup.Registry

  def start(_type, _args) do
    Registry.register_lexer(MakeupGraphql,
      options: [],
      names: ["graphql"],
      extensions: ["graphql"]
    )

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
