defmodule MakeupGraphql.Helpers do
  import Makeup.Lexer.Combinators
  import NimbleParsec

  def ignored() do
    unicode_bom = ignore(utf8_char([0xFEFF]))

    whitespace = ascii_string([?\t, ?\s], min: 1) |> token(:whitespace)

    line_terminator =
      choice([
        ascii_char([?\n]),
        ascii_char([?\r]) |> optional(ascii_char([?\n]))
      ])
      |> token(:whitespace)

    comment =
      string("#")
      |> repeat(lookahead_not(ascii_char([?\n, ?\r])) |> utf8_char([]))
      |> token(:comment_single)

    comma = ascii_char([?,]) |> token(:punctuation)

    choice([
      unicode_bom,
      whitespace,
      line_terminator,
      comment,
      comma
    ])
  end

  def ignore_whitespace(combinator) do
    ignored = ignored()
    repeat(ignored) |> concat(combinator) |> repeat(ignored)
  end

  def ignore_whitespace(combinator, ttype), do: ignore_whitespace(combinator |> token(ttype))

  def name(), do: chars() |> ignore_whitespace(:name)

  def class(), do: chars() |> ignore_whitespace(:name_class)

  def func(), do: chars() |> ignore_whitespace(:name_function)

  def symbol(), do: chars() |> ignore_whitespace(:string_symbol)

  def keyword(name) when is_binary(name) do
    name |> string() |> ignore_whitespace(:keyword_reserved)
  end

  def constant(name) when is_binary(name) do
    name |> string() |> ignore_whitespace(:name_constant)
  end

  defp chars() do
    ascii_char([?_, ?a..?z, ?A..?Z]) |> repeat(ascii_char([?_, ?0..?9, ?a..?z, ?A..?Z]))
  end
end
