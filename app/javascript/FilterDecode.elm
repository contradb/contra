module FilterDecode exposing (..)

import Json.Decode
import FakeJSLibFigure as LibFigure exposing (FilterExpression(..))

filterExpression : Json.Decode.Decoder LibFigure.FilterExpression
filterExpression =
    let
        keyFromFirstElement string =
            case string of
                "formation" ->
                    Json.Decode.andThen (Formation >> Json.Decode.succeed) (Json.Decode.index 1 Json.Decode.string)

                "progression" ->
                    Json.Decode.succeed Progression

                "figure" ->
                    Json.Decode.andThen figureDecoder (Json.Decode.index 1 Json.Decode.string)

                _ ->
                    Json.Decode.fail <| "Sorry pal, I only grok a few filters so far, and '" ++ string ++ "' isn't one of them"

        figureDecoder moveStr =
            case LibFigure.toMove moveStr of
                Just move ->
                    Json.Decode.succeed <| Figure move []

                Nothing ->
                    Json.Decode.fail <| "Trying to decode a non-move: " ++ moveStr

    in
    Json.Decode.andThen keyFromFirstElement (Json.Decode.index 0 Json.Decode.string)

-- ["&",["figure","circle"],["progression"]]
-- ["&",["figure","circle","true","270","*"],["progression"]]
-- Json.Decode.decodeString FilterDecode.filterExpression """["&",["figure","circle"],["progression"]]"""
-- Json.Decode.decodeString FilterDecode.filterExpression """["figure","circle","true","270","*"]"""
-- Json.Decode.decodeString FilterDecode.filterExpression """["figure","circle"]"""
