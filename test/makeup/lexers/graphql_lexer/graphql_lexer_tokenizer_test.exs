defmodule GraphqlLexerTokenizerTestSnippet do
  use ExUnit.Case, async: false
  import MakeupGraphql.Testing

  test "empty query" do
    assert lex("{}") == [{:punctuation, %{}, "{"}, {:punctuation, %{}, "}"}]
  end

  test "basic query" do
    query = """
    {
      hero {
        name
        appearsIn
      }
    }
    """

    expected = [
      {:punctuation, %{}, "{"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "hero"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "{"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "    "},
      {:name, %{}, "name"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "    "},
      {:name, %{}, "appearsIn"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:punctuation, %{}, "}"},
      {:whitespace, %{}, "\n"},
      {:punctuation, %{}, "}"},
      {:whitespace, %{}, "\n"}
    ]

    assert lex(query) == expected
  end

  test "query with type" do
    query = """
    type Character {
      name: String!
      appearsIn: [Episode!]!
    }
    """

    expected = [
      {:keyword_reserved, %{}, "type"},
      {:whitespace, %{}, " "},
      {:name, %{}, "Character"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "{"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "name"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:name, %{}, "String"},
      {:punctuation, %{}, "!"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "appearsIn"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "["},
      {:name, %{}, "Episode"},
      {:punctuation, %{}, "!"},
      {:punctuation, %{}, "]"},
      {:punctuation, %{}, "!"},
      {:whitespace, %{}, "\n"},
      {:punctuation, %{}, "}"},
      {:whitespace, %{}, "\n"}
    ]

    assert lex(query) == expected
  end

  test "query with arguments" do
    query = """
    type Starship {
      id: ID!
      name: String!
      length(unit: LengthUnit = METER): Float
    }
    """

    expected = [
      {:keyword_reserved, %{}, "type"},
      {:whitespace, %{}, " "},
      {:name, %{}, "Starship"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "{"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "id"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:name, %{}, "ID"},
      {:punctuation, %{}, "!"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "name"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:name, %{}, "String"},
      {:punctuation, %{}, "!"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "length"},
      {:punctuation, %{}, "("},
      {:name, %{}, "unit"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:name, %{}, "LengthUnit"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "="},
      {:whitespace, %{}, " "},
      {:name, %{}, "METER"},
      {:punctuation, %{}, ")"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:name, %{}, "Float"},
      {:whitespace, %{}, "\n"},
      {:punctuation, %{}, "}"},
      {:whitespace, %{}, "\n"}
    ]

    assert lex(query) == expected
  end

  test "enum" do
    query = """
    enum Episode {
      NEWHOPE
      EMPIRE
      JEDI
    }
    """

    expected = [
      {:keyword_reserved, %{}, "enum"},
      {:whitespace, %{}, " "},
      {:name, %{}, "Episode"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "{"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "NEWHOPE"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "EMPIRE"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "JEDI"},
      {:whitespace, %{}, "\n"},
      {:punctuation, %{}, "}"},
      {:whitespace, %{}, "\n"}
    ]

    assert lex(query) == expected
  end

  test "union" do
    query = "union SearchResult = Human | Droid | Starship"

    expected = [
      {:keyword_reserved, %{}, "union"},
      {:whitespace, %{}, " "},
      {:name, %{}, "SearchResult"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "="},
      {:whitespace, %{}, " "},
      {:name, %{}, "Human"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "|"},
      {:whitespace, %{}, " "},
      {:name, %{}, "Droid"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "|"},
      {:whitespace, %{}, " "},
      {:name, %{}, "Starship"}
    ]

    assert lex(query) == expected
  end

  test "input type" do
    query = """
    input ReviewInput {
      stars: Int!
      commentary: String
    }
    """

    expected = [
      {:keyword_reserved, %{}, "input"},
      {:whitespace, %{}, " "},
      {:name, %{}, "ReviewInput"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "{"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "stars"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:name, %{}, "Int"},
      {:punctuation, %{}, "!"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "commentary"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:name, %{}, "String"},
      {:whitespace, %{}, "\n"},
      {:punctuation, %{}, "}"},
      {:whitespace, %{}, "\n"}
    ]

    assert lex(query) == expected
  end

  test "query with interface" do
    query = """
    query HeroForEpisode($ep: Episode!) {
      hero(episode: $ep) {
        name
        ... on Droid {
          primaryFunction
        }
      }
    }
    """

    expected = [
      {:keyword_reserved, %{}, "query"},
      {:whitespace, %{}, " "},
      {:name, %{}, "HeroForEpisode"},
      {:punctuation, %{}, "("},
      {:punctuation, %{}, "$"},
      {:name, %{}, "ep"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:name, %{}, "Episode"},
      {:punctuation, %{}, "!"},
      {:punctuation, %{}, ")"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "{"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "hero"},
      {:punctuation, %{}, "("},
      {:name, %{}, "episode"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "$"},
      {:name, %{}, "ep"},
      {:punctuation, %{}, ")"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "{"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "    "},
      {:name, %{}, "name"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "    "},
      {:punctuation, %{}, "..."},
      {:whitespace, %{}, " "},
      {:keyword_reserved, %{}, "on"},
      {:whitespace, %{}, " "},
      {:name, %{}, "Droid"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "{"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "      "},
      {:name, %{}, "primaryFunction"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "    "},
      {:punctuation, %{}, "}"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:punctuation, %{}, "}"},
      {:whitespace, %{}, "\n"},
      {:punctuation, %{}, "}"},
      {:whitespace, %{}, "\n"}
    ]

    assert lex(query) == expected
  end

  test "query with mutation" do
    query = """
    mutation CreateReviewForEpisode($ep: Episode!, $review: ReviewInput!) {
      createReview(episode: $ep, review: $review) {
        stars
        commentary
      }
    }
    """

    expected = [
      {:keyword_reserved, %{}, "mutation"},
      {:whitespace, %{}, " "},
      {:name, %{}, "CreateReviewForEpisode"},
      {:punctuation, %{}, "("},
      {:punctuation, %{}, "$"},
      {:name, %{}, "ep"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:name, %{}, "Episode"},
      {:punctuation, %{}, "!"},
      {:punctuation, %{}, ","},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "$"},
      {:name, %{}, "review"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:name, %{}, "ReviewInput"},
      {:punctuation, %{}, "!"},
      {:punctuation, %{}, ")"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "{"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:name, %{}, "createReview"},
      {:punctuation, %{}, "("},
      {:name, %{}, "episode"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "$"},
      {:name, %{}, "ep"},
      {:punctuation, %{}, ","},
      {:whitespace, %{}, " "},
      {:name, %{}, "review"},
      {:punctuation, %{}, ":"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "$"},
      {:name, %{}, "review"},
      {:punctuation, %{}, ")"},
      {:whitespace, %{}, " "},
      {:punctuation, %{}, "{"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "    "},
      {:name, %{}, "stars"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "    "},
      {:name, %{}, "commentary"},
      {:whitespace, %{}, "\n"},
      {:whitespace, %{}, "  "},
      {:punctuation, %{}, "}"},
      {:whitespace, %{}, "\n"},
      {:punctuation, %{}, "}"},
      {:whitespace, %{}, "\n"}
    ]

    assert lex(query) == expected
  end
end
