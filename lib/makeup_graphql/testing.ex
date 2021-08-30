defmodule MakeupGraphql.Testing do
  @moduledoc false
  alias Makeup.Lexer.Postprocess

  # This function has two purposes:
  # 1. Ensure deterministic lexer output (no random prefix)
  # 2. Convert the token values into binaries so that the output
  #    is more obvious on visual inspection
  #    (iolists are hard to parse by a human)
  def lex(text) do
    text
    |> MakeupGraphql.lex(group_prefix: "group")
    |> Postprocess.token_values_to_binaries()
    |> Enum.map(fn {ttype, meta, value} -> {ttype, Map.delete(meta, :language), value} end)
  end
end
