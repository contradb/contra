module FilterDecode exposing (..)

import Json.Decode as Dc
import FilterExpression as Fe exposing (FilterExpression(..))

filterExpression : Dc.Decoder FilterExpression
filterExpression =
    let
        keyFromFirstElement string =
            case string of
                "progression" ->
                    Dc.succeed Progression

                "formation" ->
                    Dc.andThen formationDecoder (Dc.maybe (Dc.index 1 Dc.string))

                _ ->
                    Dc.fail "I only grok a few things so far, and you're not on the list, bub"

        formationDecoder maybeString =
            case maybeString of
                Just string ->
                    Dc.succeed (Formation string)

                Nothing ->
                    Dc.fail "Expected formation to have a string parameter"

    in
    Dc.andThen keyFromFirstElement (Dc.index 0 Dc.string)
