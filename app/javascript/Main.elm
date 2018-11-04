module Main exposing (..)

import Browser
import Html exposing (Html, text, select, option, div)
import Html.Attributes exposing (style, value, class, id)
import FakeJSLibFigure exposing (FilterExpression(..), filterTypes, Move(..))
import FilterDecode

-- MODEL

type alias Model =
  {
    expression : FilterExpression
  }


-- INIT

init : (Model, Cmd Message)
init =
  ({expression = Figure Swing []}, Cmd.none)

-- VIEW

view : Model -> Html Message
view model =
  let
      filterOption filterType = option [value filterType] [text filterType]
  in
  div [class "elm-filter-page"]
      [div [class "figure-filter-root-container"]
           [div [class "figure-filter"] --
                [select [class "form-control", class "figure-filter-op"] <| List.map filterOption filterTypes
                ]]]
  -- h1 [style "display" "flex", style "justify-content" "center"] [text "Hello Elm!"]

-- MESSAGE

type Message
  = None

-- UPDATE

update : Message -> Model -> (Model, Cmd Message)
update message model =
  (model, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Message
subscriptions model =
  Sub.none

-- MAIN

main : Program (Maybe {}) Model Message
main =
  Browser.element
    {
      init = always init,
      view = view,
      update = update,
      subscriptions = subscriptions
    }
