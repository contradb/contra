import Platform
import Task
import Time



-- MAIN


main =
  Platform.worker
    { init = init
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { zone : Time.Zone
  , time : Time.Posix
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( Model Time.utc (Time.millisToPosix 0)
  , Task.perform AdjustTimeZone Time.here
  )



-- UPDATE


type Msg
  = Tick Time.Posix
  | AdjustTimeZone Time.Zone


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      ( { model | time = newTime }
      , Cmd.none
      )

    AdjustTimeZone newZone ->
      ( { model | zone = newZone }
      , Cmd.none
      )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every 1000 Tick



-- view : Model -> Html Msg
-- view model =
--   let
--     hour   = String.fromInt (Time.toHour   model.zone model.time)
--     minute = String.fromInt (Time.toMinute model.zone model.time)
--     second = String.fromInt (Time.toSecond model.zone model.time)
--   in
--   h1 [] [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]



-- ________________________________________________________________

-- port module MyWorker exposing (..)
-- -- import Json.Encode
-- import Time

-- -- port cache : Json.Encode.Value -> Cmd msg


-- subscriptions : Model -> Sub Msg
-- subscriptions model =
--   Time.every 1000 Tick

-- -- MODEL

-- type alias Model = { time : Time.Posix }


-- -- UPDATE

-- type Msg
--   = Tick Time.Posix

-- update : Msg -> Model -> (Model, Cmd msg)
-- update msg model =
--   case msg of
--     Tick t -> ({ time = t }, Cmd.none)

-- worker :
--     { init : flags -> ( Model, Cmd msg )
--     , update : Msg -> Model -> ( Model, Cmd Msg )
--     , subscriptions : Model -> Sub msg
--     }

-- worker = { init = (\_ -> (0, Cmd.none))
--          , update = update
--          , subscriptions = (\_ -> Time.every 1000 Tick)}




-- brianhicks [9:31 AM]
-- architecture: you could totally port this to Elm and call it from a worker (https://package.elm-lang.org/packages/elm/core/latest/Platform#worker). You'd set yourself up some in/out ports in a special Main file designed to be called from the server and do a single rubyracer invocation to start the app and call the port, then wait for a response.
-- minor note: `Json.Decode.map a` is equivalent to `Json.Decode.andThen (a >> Json.Decode.succeed)` and is much nicer to maintain.
-- as far as code generation: yeah, that happens. It'll be better in the long run to generate the types for this kind of integration so that you can maintain a single source of truth.
-- that way, if the source of truth diverges from the code your Elm stuff expects then you will get compilation errors.
-- I took this approach for the elm-conf.us site this year: a script examines markdown files in a directory and builds a routing table so that the code cannot generate invalid URLs (outside of the markdown content, that is)
-- this is also how elm-graphql and elm-typescript work. Check out Dillon Kearns' talk from this year's elm-conf for why: https://2018.elm-conf.us/schedule/dillon-kearns    
