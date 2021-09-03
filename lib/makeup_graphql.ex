defmodule MakeupGraphql do
  @moduledoc """
  A `Makeup` lexer for GraphQL.
  """

  import Makeup.Lexer.Combinators
  import Makeup.Lexer.Groups
  import MakeupGraphql.Helpers
  import NimbleParsec

  @behaviour Makeup.Lexer

  @impl Makeup.Lexer
  def lex(text, opts \\ []) do
    group_prefix = Keyword.get(opts, :group_prefix, random_prefix(10))
    {:ok, tokens, "", _, _, _} = root(text)

    tokens
    |> postprocess([])
    |> match_groups(group_prefix)
  end

  @impl Makeup.Lexer
  def postprocess(tokens, _opts \\ []), do: tokens

  @impl Makeup.Lexer
  defgroupmatcher(:match_groups,
    parentheses: [
      open: [[{:punctuation, %{language: :graphql}, "("}]],
      close: [[{:punctuation, %{language: :graphql}, ")"}]]
    ],
    list: [
      open: [
        [{:punctuation, %{language: :graphql}, "["}]
      ],
      close: [
        [{:punctuation, %{language: :graphql}, "]"}]
      ]
    ],
    curly: [
      open: [
        [{:punctuation, %{language: :graphql}, "{"}]
      ],
      close: [
        [{:punctuation, %{language: :graphql}, "}"}]
      ]
    ]
  )

  # TODO: Ignore whitespace around these guys
  exclamation = ascii_char([?!])
  dollar = ascii_char([?$])
  open_paren = ascii_char([?(])
  close_paren = ascii_char([?)])
  colon = ascii_char([?:])
  _equals = ascii_char([?=])
  at = ascii_char([?@])
  open_square = ascii_char([?[])
  close_square = ascii_char([?]])
  open_bracket = ascii_char([?{])
  close_bracket = ascii_char([?}])
  _pipe = ascii_char([?|])

  negative_sign = ascii_char([?-])

  digit = ascii_char([?0..?9])

  non_zero_digit = ascii_char([?1..?9])

  integer_part =
    optional(negative_sign)
    |> choice([
      ascii_char([?0]),
      non_zero_digit |> repeat(digit)
    ])

  int_value = integer_part

  fractional_part =
    ascii_char([?.])
    |> times(digit, min: 1)

  exponent_indicator = ascii_char([?e, ?E])

  sign = ascii_char([?+, ?-])

  exponent_part =
    exponent_indicator
    |> optional(sign)
    |> times(digit, min: 1)

  float_value =
    choice([
      integer_part |> concat(fractional_part) |> concat(exponent_part),
      integer_part |> post_traverse(:fill_mantissa) |> concat(exponent_part),
      integer_part |> concat(fractional_part)
    ])

  unicode_char_in_string =
    string("\\u")
    |> ascii_string([?0..?9, ?a..?f, ?A..?F], 4)
    |> token(:string_escape)

  escaped_char =
    string("\\")
    |> utf8_string([], 1)
    |> token(:string_escape)

  combinators_inside_string = [
    unicode_char_in_string,
    escaped_char
  ]

  single_string_value = string_like("\"", "\"", combinators_inside_string, :string)
  block_string_value = string_like(~S["""], ~S["""], combinators_inside_string, :string)

  string_value = choice([single_string_value, block_string_value])

  operation_type = choice([keyword("query"), keyword("mutation"), keyword("subscription")])
  boolean_value = choice([constant("true"), constant("false")])

  alias_ = name() |> ascii_char([?:])

  variable = dollar |> concat(symbol())

  null_value = constant("null")

  enum_value = lookahead_not(choice([boolean_value, null_value])) |> concat(class())

  list_value = many_surrounded_by(parsec(:value), open_square, close_square)

  object_field = symbol() |> concat(colon) |> parsec(:value)

  object_value = many_surrounded_by(object_field, open_bracket, close_bracket)

  defcombinatorp(
    :value,
    choice([
      variable,
      int_value,
      float_value,
      string_value,
      boolean_value,
      null_value,
      enum_value,
      list_value,
      object_value
    ])
  )

  list_value_const = many_surrounded_by(parsec(:value_const), open_square, close_square)

  object_field_const = symbol() |> concat(colon) |> parsec(:value_const)

  object_value_const = many_surrounded_by(object_field_const, open_bracket, close_bracket)

  defcombinatorp(
    :value_const,
    choice([
      int_value,
      float_value,
      string_value,
      boolean_value,
      null_value,
      enum_value,
      list_value_const,
      object_value_const
    ])
  )

  argument = symbol() |> concat(colon) |> parsec(:value)

  arguments = many_surrounded_by(argument, open_paren, close_paren)

  directive = at |> concat(func()) |> optional(arguments)

  directives = directive |> repeat(directive)

  fragment_name = lookahead_not(keyword("on")) |> concat(name())

  fragment_spread =
    string("...") |> token(:punctuation) |> concat(fragment_name) |> optional(directives)

  named_type = class()
  list_type = many_surrounded_by(parsec(:type), open_square, close_square)

  non_null_type =
    choice([
      named_type |> concat(exclamation),
      list_type |> concat(exclamation)
    ])

  defcombinatorp(
    :type,
    choice([
      non_null_type,
      named_type,
      list_type
    ])
  )

  default_value = parsec(:value_const)

  variable_definition =
    variable |> concat(colon) |> concat(parsec(:type)) |> optional(default_value)

  variable_definitions = many_surrounded_by(variable_definition, open_paren, close_paren)

  selection_set = many_surrounded_by(parsec(:selection), open_bracket, close_bracket)

  type_condition = keyword("on") |> concat(named_type)

  fragment =
    string("fragment")
    |> concat(fragment_name)
    |> concat(type_condition)
    |> optional(directives)
    |> concat(selection_set)

  inline_fragment =
    string("...")
    |> token(:punctuation)
    |> optional(type_condition)
    |> optional(directives)
    |> concat(selection_set)

  field =
    optional(alias_)
    |> concat(name())
    |> optional(arguments)
    |> optional(directives)
    |> optional(selection_set)

  defcombinatorp(
    :selection,
    choice([
      field,
      fragment_spread,
      inline_fragment
    ])
  )

  operation =
    choice([
      operation_type
      |> optional(func())
      |> optional(variable_definitions)
      |> optional(directives)
      |> concat(selection_set),
      selection_set
    ])

  executable = choice([operation, fragment])

  root_operation_type_definition = operation_type |> concat(colon) |> concat(named_type)

  # TODO: Also const directives?
  schema_definition =
    keyword("schema")
    |> optional(directives)
    |> concat(open_bracket)
    |> concat(root_operation_type_definition)
    |> repeat(root_operation_type_definition)
    |> concat(close_bracket)

  description = string_value

  implements_interfaces =
    keyword("implements")
    |> optional(ascii_char([?&]))
    |> concat(named_type)
    |> repeat(ascii_char([?&]) |> concat(named_type))

  input_value_definition =
    optional(description)
    |> concat(class())
    |> concat(colon)
    |> parsec(:type)
    |> optional(default_value)
    |> optional(directives)

  arguments_definition =
    open_paren
    |> concat(input_value_definition)
    |> repeat(input_value_definition)
    |> concat(close_paren)

  # TODO: Also const directives?
  field_definition =
    optional(description)
    |> concat(class())
    |> optional(arguments_definition)
    |> concat(colon)
    |> parsec(:type)
    |> optional(directives)

  fields_definition =
    open_bracket |> concat(field_definition) |> repeat(field_definition) |> concat(close_bracket)

  # TODO: Also const directives?
  scalar_type_definition =
    optional(description) |> concat(keyword("scalar")) |> concat(class()) |> optional(directives)

  object_type_definition =
    optional(description)
    |> concat(keyword("type"))
    |> concat(class())
    |> optional(implements_interfaces)
    |> optional(directives)
    |> optional(fields_definition)

  type_definition =
    choice([
      scalar_type_definition,
      object_type_definition
      # interface_type_definition,
      # union_type_definition,
      # enum_type_definition,
      # input_object_definition
    ])

  directive_definition = empty()

  type_system_definition =
    choice([
      schema_definition,
      type_definition,
      directive_definition
    ])

  definition =
    choice([
      executable,
      type_system_definition
      # type_system_extension
    ])

  document = repeat(ignored()) |> concat(definition) |> repeat(definition)

  defparsec(
    :root,
    document |> map(:as_graphql_language)
  )

  defparsec(
    :root_element,
    string("TODO")
  )

  defp as_graphql_language({ttype, meta, value}) do
    {ttype, Map.put(meta, :language, :graphql), value}
  end

  defp fill_mantissa(_rest, raw, context, _, _), do: {'0.' ++ raw, context}
end
